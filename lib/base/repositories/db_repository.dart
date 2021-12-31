import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/base/repositories/db_abstract_repository.dart';
import 'package:consumer_basket/base/logger.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';

typedef DependentAction<ItemT extends AbstractRepositoryItem<ItemT>, DepItemT extends AbstractRepositoryItem<DepItemT>> =
    Function(DependentDbField<ItemT,DepItemT>, ItemT, DepItemT);

abstract class DbRepository<ItemT extends AbstractRepositoryItem<ItemT>>
    extends AbstractDbRepository<ItemT> {

  @override
  String get tableName => _tableName;
  late String _tableName;

  @override
  Map<String, DependentRepositoryInfo> get dependentRepositoriesByType => _dependentRepositoriesByType;
  Map<String, DependentRepositoryInfo> _dependentRepositoriesByType = {};

  @override
  List<Hook<ItemT>> get onInsertHooks => _onInsertHooks;
  final List<Hook<ItemT>> _onInsertHooks = [];

  @override
  List<Hook<ItemT>> get onUpdateHooks => _onUpdateHooks;
  final List<Hook<ItemT>> _onUpdateHooks = [];

  @override
  List<Hook<ItemT>> get onDeleteHooks => _onDeleteHooks;
  final List<Hook<ItemT>> _onDeleteHooks = [];


  @override
  Map<String,DbField> get fieldsByName => _dbFieldsByName;
  late Map<String,DbField> _dbFieldsByName;

  late Database _db;
  late List<DbField<ItemT,dynamic>> _simpleFields;
  late List<RelativeDbField<ItemT,dynamic>> _relativeFields;
  // depType -> depField
  late Map<String,DependentDbField<ItemT, dynamic>> _depFieldByType;
  late ItemCreator<ItemT> _itemCreator;
  Map<int,ItemT>? _itemsCache;

  final Logger _logger = Logger("BaseRepository<${ItemT.toString()}>");

  static const String _columnIdName = 'id';

  @override
  init(
        String table,
        ItemCreator<ItemT> itemCreator,
        List<AbstractField> fields
        ){
    _tableName = table;
    _dbFieldsByName = {};
    _simpleFields = [];
    _relativeFields = [];
    _depFieldByType = {};
    for(var field in fields){
      if(field is DbField<ItemT,dynamic>) {
        field.tableName = tableName;
        if (field is RelativeDbField<ItemT, dynamic>) {
          _relativeFields.add(field);
          field.setDependentRepository(
              this,
              (int? id) async => await _handleRelativeDeletion(field as RelativeDbField, id),
              (AbstractDbRepository rep, ItemT item) async {
                return await (rep as DbRepository)._handleDependentInsertion(item);
              },
              (AbstractDbRepository rep, ItemT item) async {
                await (rep as DbRepository)._handleDependentDeletion(item);
              },
          );
        } else {
          _simpleFields.add(field);
        }
        _dbFieldsByName[field.columnName] = field;
      } else if(field is DependentDbField<ItemT, dynamic>){
        _depFieldByType[field.fieldType] = field;
      } else {
        _logger.error("Unexpected field: ${field.runtimeType}");
      }
    }
    _itemCreator = itemCreator;
    _logger.info("successfully initialized");
  }

  @override
  set db(Database db) {
    _db = db;
    _itemsCache = null;
  }

  // returns items as id->value (get form cache or get from db and create cache)
  @override
  Future<Map<int,ItemT>> getAll() async {
    if(_itemsCache != null){
      return _itemsCache!;
    }
    _itemsCache = <int,ItemT>{};
    List<Map<String, dynamic>> raw_objs = await _db.query(_tableName);
    for (var raw_obj in raw_objs){
      ItemT? obj = await fromDbMap(raw_obj);

      if(obj == null){
        _logger.subModule("getAll()").error("fromMap() returns null obj, skip it");
        continue;
      }
      obj.repository = this;
      int id = raw_obj[_columnIdName] as int;
      obj.id = id;
      _itemsCache![id] = obj;

      for(var field in _depFieldByType.values) {
        await field.set(obj,this);
      }
    }
    return _itemsCache!;
  }

  // returns items cache if it exists
  @override
  Map<int,ItemT>? getAllCache() {
    return _itemsCache;
  }

  // return items with certen relative field
  @override
  Future<Map<int,ItemT>> getByRelative<
    FieldT extends  AbstractRepositoryItem<FieldT>
    >(RelativeDbField<ItemT,FieldT> field, FieldT relative) async {
    if(relative.id == null){
      _logger.subModule("getByRelative<${FieldT.toString()}>()").error("relative id is null");
    }
    return await getByDbField(field, relative.id!);
  }


  // return items with certen field (do not check that index exists)
  @override
  Future<Map<int,ItemT>> getByDbField<FieldT>(DbField<ItemT,dynamic> field, FieldT value) async{
    var logger = _logger.subModule("getByField<${FieldT.toString()}>()");
    Map<int,ItemT> result = {};
    var allItems = await getAll();
    List<Map> rawResult = await _db.rawQuery("""
      SELECT $_columnIdName 
      FROM $_tableName 
      WHERE ${field.columnName} = $value;
    """);
    for(var row in rawResult){
      var id = row["id"];
      var item = allItems[id];
      if(item != null){
        result[id] = item;
      } else {
        logger.error("item not found in cache for id=$id");
      }
    }
    return result;
  }

  // returns dependnet items (from dependent repository)
  // only one dependent by type can be resolved
  @override
  Future<Map<int, DependentT>> getDependents<
    DependentT extends AbstractRepositoryItem<DependentT>
    >(ItemT item) async {
    var logger = _logger.subModule("getDependents<${DependentT.toString()}>()");
    if(!item.isValid(repository: this, logger: logger)){
      return {};
    }
    var depRep = dependentRepositoriesByType[DependentT.toString()];
    if(depRep == null){
      logger.error("dependent repository not found");
      return {};
    }
    var rep = depRep.repository as DbRepository<DependentT>;
    var field = depRep.field as RelativeDbField<DependentT,ItemT>;
    return await rep.getByRelative(field, item);
  }

  // returns inserted id or 0 if not inserted
  @override
  Future<int> insert(ItemT item) async {
    var logger = _logger.subModule("insert()");
    if(item.repository != null){
      logger.error("item already inserted");
      return 0;
    }
    Map<String, Object?>? map = await toDbMap(item);
    if(map == null){
      logger.error("no db mapping for object, can not insert");
      return 0;
    }
    if (item.id != null) {
      map[_columnIdName] = item.id;
    }
    int id = await _db.insert(_tableName, map);
    if(id != 0){
      item.repository = this;
      item.id = id;
      if(_itemsCache != null) {
        _itemsCache![id] = item;
      }
      await _callHooks(onInsertHooks, item);
      logger.info("successfully inserted");
    } else {
      logger.error("failed to insert item in db");
    }
    return id;
  }

  // returns true if success
  @override
  Future<bool> update(ItemT item) async {
    var logger = _logger.subModule("update()");
    int? id = item.id;
    if(!item.isValid(repository: this, logger: logger)){
      return false;
    }
    Map<String, Object?>? map = await toDbMap(item);
    if(map == null){
      logger.error("no db mapping for object, can not update");
      return false;
    }
    int count = await _db.update(_tableName, map, where: '$_columnIdName = ?', whereArgs: [id]);
    if(count == 0) {
      logger.error("failed to update item in db");
      return false;
    }
    await _callHooks(onUpdateHooks, item);
    logger.info("successfully updated");
    return true;
  }

  // returns true if deleted
  @override
  Future<bool> delete(ItemT item) async {
    var logger = _logger.subModule("delete()");
    if(!item.isValid(repository: this, logger: logger)){
      return false;
    }
    int id = item.id!;
    bool deleted = await _deleteById(id);
    if(deleted) {
      item.repository = null;
      if (_itemsCache != null ) {
        _itemsCache!.remove(id);
      }
      await _callHooks(onDeleteHooks, item);
    }
    return deleted;
  }

  @override
  Future<Map<String, Object?>?> toDbMap(ItemT item) async{
    var map = <String, Object?>{};
    for(var field in _dbFieldsByName.values){
      map[field.columnName] = field.abstractGet(item);
    }
    return map;
  }

  @override
  Future<ItemT?> fromDbMap(Map map) async{
    var item = _itemCreator();
    for(var field in _relativeFields){
      await field.relativeRepository.getAll(); // create cache
      field.abstractSet(item, map[field.columnName]);
    }
    for(var field in _simpleFields) {
      field.abstractSet(item, map[field.columnName]);
    }
    return item;
  }

  _handleDependentInsertion<DepItemT extends AbstractRepositoryItem<DepItemT>>(DepItemT depItem) async {
    var logger = _logger.subModule("handleDependentInsertion<${DepItemT.toString()}>()");
    await _handleDependentAction(
        depItem,
        (DependentDbField<ItemT,DepItemT> depField, ItemT myItem, DepItemT depItem) {
          depField.onInsert(myItem, depItem);
        },
        logger
    );
  }

  _handleDependentDeletion<DepItemT extends AbstractRepositoryItem<DepItemT>>(DepItemT depItem) async {
    var logger = _logger.subModule("handleDependentDeletion<${DepItemT.toString()}>()");
    await _handleDependentAction(
        depItem,
        (DependentDbField<ItemT,DepItemT> depField, ItemT myItem, DepItemT depItem) {
          depField.onDelete(myItem, depItem);
        },
        logger
    );
  }

  _handleDependentAction<DepItemT extends AbstractRepositoryItem<DepItemT>>(
      DepItemT depItem, DependentAction<ItemT, DepItemT> depAction, Logger logger) async {
    if(_itemsCache == null){
      return;
    }
    var depTypeStr =  DepItemT.toString();

    if(!depItem.isValid(logger:logger)){
      return;
    }
    var depField = _depFieldByType[depTypeStr] as DependentDbField<ItemT,DepItemT>?;
    if(depField == null){
      logger.info("dependent field not found for type ${depTypeStr}");
      return;
    }
    var depRep = dependentRepositoriesByType[depTypeStr];
    if(depRep == null){
      logger.error("dependent repository does not exist for type $depTypeStr");
      return;
    }
    var fieldInDepRep = depRep.field as RelativeDbField<DepItemT, ItemT>;
    var myItemId = fieldInDepRep.getter(depItem);
    if(myItemId == null){
      logger.error("there is no relative id in dependent item");
      return;
    }
    var myItem = _itemsCache![myItemId];
    if(myItem == null){
      logger.error("there is no item in cache with id=$myItemId");
      return;
    }
    depAction(depField, myItem, depItem);
  }


  Future<bool> _deleteById(int id) async {
    var logger = _logger.subModule("_deleteById()");
    int deleteCount = await _db.delete(_tableName, where: 'id = ?', whereArgs: [id]);
    if(deleteCount == 0) {
      logger.error("failed to delete in db");
      return false;
    }
    logger.info("successfully deleted");
    return true;
  }

  Future<void> _handleRelativeDeletion(RelativeDbField field, int? id) async{
    if(id == null){
      return;
    }
    if(_itemsCache != null){
      for(var item in _itemsCache!.values){
        int? fieldId = field.abstractGet(item) as int?;
        if(fieldId == id){
          field.abstractSet(item, null);
        }
      }
    }
    await _db.execute("""
      UPDATE $_tableName 
      SET ${field.columnName} = NULL
      WHERE ${field.columnName} = $id;
    """);
  }

  Future<void> _callHooks(List<Hook<ItemT>> hooks, ItemT item) async{
    for(var hook in hooks){
      await hook(item);
    } 
  } 
}
