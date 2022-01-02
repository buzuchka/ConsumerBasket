import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/base/repositories/db_repository_supervisor.dart';
import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/base/repositories/db_abstract_repository.dart';
import 'package:consumer_basket/helpers/logger.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';

typedef DependentAction<ItemT extends AbstractRepositoryItem<ItemT>, DepItemT extends AbstractRepositoryItem<DepItemT>> =
    Function(DependentField<ItemT,DepItemT>, ItemT, DepItemT);


abstract class DbRepository<ItemT extends AbstractRepositoryItem<ItemT>>
    extends AbstractDbRepository<ItemT> {

  @override
  DbRepositorySupervisor get supervisor => _supervisor;
  late DbRepositorySupervisor _supervisor;

  @override
  String get tableName => _tableName;
  late String _tableName;

  @override
  Map<String, DependentRepositoryInfo> get dependentRepositoriesByType => _dependentRepositoriesByType;
  Map<String, DependentRepositoryInfo> _dependentRepositoriesByType = {};

  @override
  List<Hook<ItemT>> get onCacheInsertHooks => _onCacheInsertHooks;
  final List<Hook<ItemT>> _onCacheInsertHooks = [];

  @override
  List<Hook<ItemT>> get onCacheDeleteHooks => _onCacheDeleteHooks;
  final List<Hook<ItemT>> _onCacheDeleteHooks = [];

  @override
  List<Hook<ItemT>> get onCacheUpdateHooks => _onCacheUpdateHooks;
  final List<Hook<ItemT>> _onCacheUpdateHooks = [];

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
  final Map<String,DbField> _dbFieldsByName = {};

  static const String columnIdName = 'id';

  late Database _db;
  final List<DbField<ItemT,dynamic>> _simpleFields = [];
  final List<RelativeDbField<ItemT,dynamic>> _relativeFields = [];

  // depType -> depFields
  final Map<String,List<DependentField<ItemT, dynamic>>> _depFieldsByType = {};

  @override
  Map<String, List<SubscribedField<dynamic>>> get subscribedFieldsByType => _subscribedFieldsByType;
  // publisherType -> subscribedFields
  final Map<String, List<SubscribedField<dynamic>>> _subscribedFieldsByType = {};

  late ItemCreator<ItemT> _itemCreator;
  Map<int,ItemT>? _itemsCache;

  final Logger _logger = Logger("BaseRepository<${ItemT.toString()}>");


  @override
  init(
        String table,
        ItemCreator<ItemT> itemCreator,
        List<AbstractField> fields
        ){
    _tableName = table;
    for(var field in fields){
      if(field is DbField<ItemT,dynamic>) {
        field.tableName = tableName;
        if (field is RelativeDbField<ItemT, dynamic>) {
          _relativeFields.add(field);
          // field.resolveDependencies(
          //     this,
          //     (int? id) async => await _handleRelativeDeletion(field as RelativeDbField, id),
          //     (AbstractDbRepository rep, ItemT item) async {
          //       await (rep as DbRepository)._handleDependentInsert(item);
          //     },
          //     (AbstractDbRepository rep, ItemT item) async {
          //       await (rep as DbRepository)._handleDependentDelet(item);
          //     },
          //     (AbstractDbRepository rep, ItemT item) async {
          //       await (rep as DbRepository)._handleDependentUpdate(item);
          //     },
          // );
        } else {
          _simpleFields.add(field);
        }
        _dbFieldsByName[field.columnName] = field;
      } else if(field is DependentField<ItemT, dynamic>){
        var depFields = _depFieldsByType.putIfAbsent(field.fieldType, () => []);
        depFields.add(field);
      } else if (field is SubscribedField) {
        var subFields = _subscribedFieldsByType.putIfAbsent(field.fieldType, () => []);
        subFields.add(field);
      } else {
        _logger.error("Unexpected field: ${field.runtimeType}");
      }
    }
    _itemCreator = itemCreator;
    _logger.info("successfully initialized");
  }

  @override
  resolveDependencies(DbRepositorySupervisor supervisor) {
    _supervisor = supervisor;
    for(var subFields in subscribedFieldsByType.values){
      for(var subField in subFields){
        var publisher = supervisor.getRepositoryByTypeName(subField.fieldType);
        if(publisher == null){
          _logger.error("Publisher not found for type=${subField.fieldType}");
        } else {
          subField.subscribe(publisher);
        }
      }
    }
    for(var field in _relativeFields){
      field.resolveDependencies(
          this,
          supervisor,
          (int? id) async => await _handleRelativeDeletion(field as RelativeDbField, id),
          (AbstractDbRepository rep, ItemT item) async {
            await (rep as DbRepository)._handleDependentInsert(item);
          },
          (AbstractDbRepository rep, ItemT item) async {
            await (rep as DbRepository)._handleDependentDelet(item);
          },
          (AbstractDbRepository rep, ItemT item) async {
            await (rep as DbRepository)._handleDependentUpdate(item);
          },
      );
    }
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
      ItemT? item = await fromDbMap(raw_obj);
      if(item == null){
        _logger.subModule("getAll()").error("fromMap() returns null item, skip it");
        continue;
      }
      _itemsCache![item.id!] = item;
    }
    for(var item in _itemsCache!.values) {
      await _callHooks(onCacheInsertHooks, item);
    }
    for(var depRep in dependentRepositoriesByType.values){
      await depRep.repository.getAll();
    }
    return _itemsCache!;
  }

  @override
  Future<List<ItemT>> getAllOrdered() async {
    return (await getAll()).values.toList();
  }

  // returns items cache if it exists
  @override
  Map<int,ItemT>? getAllCache() {
    return _itemsCache;
  }

  Future<List<ItemT>> getOrdered(
      String orderColumnName,
      {Ordering? ordering, int? limitCount, int? offsetCount, String? whereClause}) async {
    ordering ??= Ordering.desc;
    String order ="ORDER BY $orderColumnName ${ordering.toString().split(".").last}";
    String where = "";
    if(whereClause != null){
      where = "WHERE $whereClause";
    }
    String limit = "";
    if(limitCount != null){
      limit = "LIMIT $limitCount";
      if(offsetCount !=null){
        limit = "$limit OFFSET $offsetCount";
      }
    }
    return await getByQueryOrdered(
        """
          SELECT $columnIdName 
          FROM $_tableName 
          $where $order $limit
          ;
        """,
        _logger.subModule("getOrdered()")
    );
  }

  // return items with certain relative field
  @override
  Future<Map<int,ItemT>> getByRelative<
    FieldT extends  AbstractRepositoryItem<FieldT>
    >(RelativeDbField<ItemT,FieldT> field, FieldT relative) async {
    if(relative.id == null){
      _logger.subModule("getByRelative<${FieldT.toString()}>()").error("relative id is null");
    }
    return await getByDbField(field.columnName, relative.id!);
  }


  // return items with certain field (do not check that index exists)
  @override
  Future<Map<int,ItemT>> getByDbField<FieldT>(String columnName, FieldT value) async{
    return await getByQueryMapped(
        """
          SELECT $columnIdName 
          FROM $_tableName 
          WHERE $columnName = $value;
        """,
        _logger.subModule("getByField<${FieldT.toString()}>()")
    );
  }

  // Returns ordered item list by query.  Query should return ids.
  @override
  Future<List<ItemT>> getByQueryOrdered(String query, [Logger? logger]) async{
    List<ItemT> result = [];
    logger ??= _logger.subModule("getByQueryOrdered()");
    await getByQuery(query,(ItemT item) => result.add(item), logger);
    return result;
  }

  // Returns mapped items by query. Query should return ids.
  @override
  Future<Map<int,ItemT>> getByQueryMapped(String query, [Logger? logger]) async{
    Map<int,ItemT> result = {};
    logger ??= _logger.subModule("getByQueryMapped()");
    await getByQuery(query,(ItemT item) => result[item.id!] = item, logger);
    return result;
  }

  // Inserts items by query. Query should return ids.
  @override
  getByQuery(String query, ItemInserter<ItemT> itemInserter, [Logger? logger]) async {
    logger ??= _logger.subModule("getByQuery()");
    logger.info("Query: \n$query");
    var allItems = await getAll();
    List<Map> rawResult = await _db.rawQuery(query);
    logger.info("got ${rawResult.length} items");
    for(var row in rawResult){
      var id = row["id"];
      var item = allItems[id];
      if(item != null){
        itemInserter(item);
      } else {
        logger.error("item not found in cache for id=$id");
      }
    }
  }

  // returns dependent items (from dependent repository)
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
      map[columnIdName] = item.id;
    }
    int id = await _db.insert(_tableName, map);
    if(id != 0){
      item.repository = this;
      item.id = id;
      if(_itemsCache != null) {
        _itemsCache![id] = item;
        await _callHooks(onCacheInsertHooks, item);
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
    int count = await _db.update(_tableName, map, where: '$columnIdName = ?', whereArgs: [id]);
    if(count == 0) {
      logger.error("failed to update item in db");
      return false;
    }
    if(_itemsCache != null){
      await _callHooks(onCacheUpdateHooks, item);
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
      await _callHooks(onDeleteHooks, item);
      if (_itemsCache != null ) {
        _itemsCache!.remove(id);
        await _callHooks(onCacheDeleteHooks, item);
      }
      item.repository = null;
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
    item.id = map[columnIdName] as int;
    item.repository = this;
    for(var field in _relativeFields){
      await field.relativeRepository.getAll(); // create cache
      field.abstractSet(item, map[field.columnName]);
    }
    for(var field in _simpleFields) {
      field.abstractSet(item, map[field.columnName]);
    }

    return item;
  }

  _handleDependentInsert<DepItemT extends AbstractRepositoryItem<DepItemT>>(DepItemT depItem) async {
    await _handleDependentAction(
        depItem,
        (DependentField<ItemT,DepItemT> depField, ItemT myItem, DepItemT depItem) {
          _invokeDependentHook(depField.onCacheInsert, myItem, depItem);
        },
        _logger.subModule("handleDependentInsertion<${DepItemT.toString()}>()")
    );
  }

  _handleDependentDelet<DepItemT extends AbstractRepositoryItem<DepItemT>>(DepItemT depItem) async {
    await _handleDependentAction(
        depItem,
        (DependentField<ItemT,DepItemT> depField, ItemT myItem, DepItemT depItem) {
          _invokeDependentHook(depField.onCacheDelete, myItem, depItem);
        },
        _logger.subModule("handleDependentDeletion<${DepItemT.toString()}>()")
    );
  }

  _handleDependentUpdate<DepItemT extends AbstractRepositoryItem<DepItemT>>(DepItemT depItem) async {
    await _handleDependentAction(
        depItem,
        (DependentField<ItemT,DepItemT> depField, ItemT myItem, DepItemT depItem) {
          _invokeDependentHook(depField.onCacheUpdate, myItem, depItem);
        },
        _logger.subModule("_handleDependentUpdate<${DepItemT.toString()}>()")
    );
  }

  _handleDependentAction<DepItemT extends AbstractRepositoryItem<DepItemT>>(
      DepItemT depItem, DependentAction<ItemT, DepItemT> depAction, Logger logger) async {
    logger.info("start handle dependent action");
    if(_itemsCache == null){
      logger.info("Cache is null. Nothing to do.");
      return;
    }
    var depTypeStr =  DepItemT.toString();

    if(!depItem.isValid(logger:logger)){
      logger.debug("depItem is not valid");
      return;
    }
    var depFields = _depFieldsByType[depTypeStr] as List<DependentField<ItemT,dynamic>>?;
    if(depFields == null || depFields.isEmpty){
      logger.info("dependent field not found for type $depTypeStr");
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
    for (var depField in depFields) {
      depAction(depField as DependentField<ItemT,DepItemT>, myItem, depItem);
    }
    logger.info("successfully handled");
  }

  _invokeDependentHook<DepFieldT extends AbstractRepositoryItem<DepFieldT>>(
      DependentHook<ItemT, DepFieldT>? hook, ItemT item, DepFieldT depFieldVal){
    if(hook != null){
      hook(item, depFieldVal);
    }
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
