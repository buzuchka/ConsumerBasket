import 'package:consumer_basket/base/repositories/repository_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/base/repositories/abstract_repository.dart';
import 'package:consumer_basket/base/logger.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';

typedef Hook<ItemT> = Future<void> Function(ItemT);

typedef ItemCreator<ItemT> = ItemT Function();

class DependentRepositoryInfo{
  RelativeDbField field;
  DbRepository repository;
  DependentRepositoryInfo(this.field, this.repository);
}

abstract class DbRepository<ItemT extends RepositoryItem<ItemT>>
    extends AbstractRepository<ItemT> {

  late String table;

  // dependent item type -> repository
  Map<String, DependentRepositoryInfo> dependentRepositoriesByType = {};

  List<Hook<ItemT>> onInsertHooks = [];
  List<Hook<ItemT>> onUpdateHooks = [];
  List<Hook<ItemT>> onDeleteHooks = [];

  late Database _db;
  late String _schema;
  late String _indexes;
  late List<DbField> _allFields;
  late List<DbField> _simpleFields;
  late List<RelativeDbField> _relativeFields;
  late ItemCreator<ItemT> _itemCreator;
  Map<int,ItemT>? _itemsCache;

  final Logger _logger = Logger("BaseRepository<${ItemT.toString()}>");

  static const String _columnIdName = 'id';

  createIfNotExists() async{
    _db.execute("""
      CREATE TABLE IF NOT EXISTS $table (
        $_columnIdName INTEGER PRIMARY KEY NOT NULL,
        $_schema
      ); 
      $_indexes
    """);

  }

  init(
        Database db,
        String table,
        ItemCreator<ItemT> itemCreator,
        List<DbField> fields
        ){
    _db = db;
    this.table = table;
    _allFields = fields;
    _simpleFields = [];
    _relativeFields = [];
    List<String> indexList = [];
    for(var field in fields){
      if(field is RelativeDbField){
        _relativeFields.add(field);
        field.setDependentRepository(this);
      } else {
        _simpleFields.add(field);
      }
      var index = field.getIndexSchema(table);
      if(index != null){
        indexList.add(index);
      }
    }
    _itemCreator = itemCreator;
    _schema = fields.join(", ");
    _indexes = indexList.join(" ");
    _logger.info("successfully inited");
  }

  // returns items as id->value (get form cache or get from db and create cache)
  @override
  Future<Map<int,ItemT>> getAll() async {
    if(_itemsCache != null){
      return _itemsCache!;
    }
    _itemsCache = <int,ItemT>{};
    List<Map<String, dynamic>> raw_objs = await _db.query(table);
    for (var raw_obj in raw_objs){
      ItemT? obj = await fromMap(raw_obj);
      if(obj == null){
        _logger.subModule("getAll()").error("fromMap() returns null obj, skip it");
        continue;
      }
      obj.repository = this;
      int id = raw_obj[_columnIdName] as int;
      obj.id = id;
      _itemsCache![id] = obj;
    }
    return _itemsCache!;
  }

  // returns items cache if it exists
  @override
  Map<int,ItemT>? getAllCache() {
    return _itemsCache;
  }


  // return items with certen relative field
  Future<Map<int,ItemT>> getByRelative<
    FieldT extends  RepositoryItem<FieldT>
    >(RelativeDbField<ItemT,FieldT> field, FieldT relative) async {
    if(relative.id == null){
      _logger.subModule("getByRelative<${FieldT.toString()}>()").error("relative id is null");
    }
    return await getByDbField(field, relative.id!);
  }

  // return items with certen field (do not check that index exists)
  Future<Map<int,ItemT>> getByDbField<FieldT>(DbField<ItemT,dynamic> field, FieldT value) async{
    var logger = _logger.subModule("getByField<${FieldT.toString()}>()");
    Map<int,ItemT> result = {};
    var allItems = await getAll();
    List<Map> rawResult = await _db.rawQuery("""
      SELECT $_columnIdName 
      FROM $table 
      WHERE ${field.name} = $value;
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
  Future<Map<int, DependentT>> getDependents<
    DependentT extends RepositoryItem<DependentT>
    >(ItemT item) async {
    var logger = _logger.subModule("getDependents<${DependentT.toString()}>()");
    if(item.isValid(repository: this, logger: logger)){
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
    Map<String, Object?>? map = await toMap(item);
    if(map == null){
      logger.error("no db mapping for object, can not insert");
      return 0;
    }
    if (item.id != null) {
      map[_columnIdName] = item.id;
    }
    int id = await _db.insert(table, map);
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
    Map<String, Object?>? map = await toMap(item);
    if(map == null){
      logger.error("no db mapping for object, can not update");
      return false;
    }
    int count = await _db.update(table, map, where: '$_columnIdName = ?', whereArgs: [id]);
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

  Future<Map<String, Object?>?> toMap(ItemT item) async{
    var map = <String, Object?>{};
    for(var field in _allFields){
      map[field.name] = field.abstractGet(item);
    }
    return map;
  }

  Future<ItemT?> fromMap(Map map) async{
    // _logger.subModule("fromMap()").error("abstract method is called");
    var item = _itemCreator();
    for(var field in _relativeFields){
      await field.relativeRepository.getAll(); // create cache
      field.abstractSet(item, map[field.name]);
    }
    for(var field in _simpleFields) {
      field.abstractSet(item, map[field.name]);
    }
    return item;
  }

  Future<bool> _deleteById(int id) async {
    var logger = _logger.subModule("_deleteById()");
    int deleteCount = await _db.delete(table, where: 'id = ?', whereArgs: [id]);
    if(deleteCount == 0) {
      logger.error("failed to delete in db");
      return false;
    }
    logger.info("successfully deleted");
    return true;
  }

  Future<void> handleRelativeDeletion(RelativeDbField field, int? id) async{
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
      UPDATE $table 
      SET ${field.name} = NULL
      WHERE ${field.name} = $id;
    """);
  }

  Future<void> _callHooks(List<Hook<ItemT>> hooks, ItemT item) async{
    for(var hook in hooks){
      await hook(item);
    } 
  } 
}
