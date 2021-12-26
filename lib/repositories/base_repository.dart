import 'package:consumer_basket/models/repository_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/repositories/abstract_repository.dart';
import 'package:consumer_basket/common/logger.dart';
import 'package:consumer_basket/repositories/db_field.dart';

typedef ItemCreator<ItemT> = ItemT Function();

class DependentRepository{
  RelativeDbField field;
  BaseDbRepository repository;
  DependentRepository(this.field, this.repository);
}

abstract class BaseDbRepository<ItemT extends RepositoryItem<ItemT>> extends AbstractRepository<ItemT> {

  late Database db;
  late String table;
  late String schema;
  late String indexes;
  late List<DbField> allFields;
  late List<DbField> simpleFields;
  late List<RelativeDbField> relativeFields;

  late ItemCreator<ItemT> itemCreator;

  // dependent item type -> repository
  Map<String, DependentRepository> dependentRepositortiesByType = {};

  String get itemType => ItemT.toString();

  List<Hook<ItemT>> onInsertHooks = [];
  List<Hook<ItemT>> onUpdateHooks = [];
  List<Hook<ItemT>> onDeleteHooks = [];

  final Logger _logger = Logger("BaseRepository<${ItemT.toString()}>");
  Map<Id,ItemT>? _itemsCache;
  
  static const String _columnIdName = 'id';

  createIfNotExists() async{
    db.execute("""
      CREATE TABLE IF NOT EXISTS $table (
        $_columnIdName INTEGER PRIMARY KEY NOT NULL,
        $schema
      ); 
      $indexes
    """);

  }

  init(
        Database db,
        String table,
        ItemCreator<ItemT> itemCreator,
        List<DbField> fields
        ){
    this.db = db;
    this.table = table;
    allFields = fields;
    simpleFields = [];
    relativeFields = [];
    List<String> indexList = [];
    for(var field in fields){
      if(field is RelativeDbField){
        relativeFields.add(field);
        var relRep = field.relativeRepository.
        relRep.dependentRepositortiesByType[field.relativeRepository.itemType] = DependentRepository(field, this);
        relRep.onDeleteHooks.add( 
          field.idHookToFieldHook(
            (Id? id){await _handleRelativeDelition(field, id);}
          ) 
        );
      } else {
        simpleFields.add(field);
      }
      var index = field.getIndexSchema(table);
      if(index){
        indexList.add(index);
      }
    }
    this.itemCreator = itemCreator;
    schema = fields.join(", ");
    indexes = indexList.join(" ");
  }

  // returns items as id->value (get form cache or get from db and create cache)
  @override
  Future<Map<Id,ItemT>> getAll() async {
    if(_itemsCache != null){
      return _itemsCache!;
    }
    _itemsCache = <Id,ItemT>{};
    List<Map<String, dynamic>> raw_objs = await db.query(table);
    for (var raw_obj in raw_objs){
      ItemT? obj = await fromMap(raw_obj);
      if(obj == null){
        _logger.subModule("getAll()").error("fromMap() returns null obj, skip it");
        continue;
      }
      obj.repository = this;
      Id id = raw_obj[_columnIdName] as Id;
      obj.id = id;
      _itemsCache![id] = obj;
    }
    return _itemsCache!;
  }

  // returns items cache if it exists
  @override
  Map<Id,ItemT>? getAllCache() {
    return _itemsCache;
  }


  // return items with certen relative field
  Future<Map<Id,ItemT>> getByRelative<
    FieldT extends  RepositoryItem<FieldT>
    >(RelativeDbField<ItemT,FieldT> field, FieldT relative) async {
    if(relative.id == null){
      _logger.subModule("getByRelative<${FieldT.toString()}>()").error("relative id is null");
    }
    return await getByField(field, relative.id!);
  }

  // return items with certen field (do not check that index exists)
  Future<Map<Id,ItemT>> getByField<FieldT>(DbField<ItemT,dynamic> field, FieldT value) async{
    var logger = _logger.subModule("getByField<${FieldT.toString()}>()");
    Map<Id,ItemT> result = {}; 
    var allItems = await getAll();
    List<Map> rawResult = await db.rawQuery("""
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
  Future<Map<Id, DependentT>> getDependents<
    DependentT extends RepositoryItem<DependentT>
    >(ItemT item) async {
    var logger = _logger.supModule("getDependents<${DependentT.toString()}>()");
    if(item.isValid(repository: this, logger: logger)){
      return {};
    }
    var depRep = dependentRepositortiesByType[DependentT.toString()];
    if(depRep == null){
      logger.error("dependent repository not found");
      return {};
    }
    var rep = depRep.repository as BaseDbRepository<DependentT>;
    return await rep.getByRelative(depRep.field, item);
  }

  // returns inserted id or 0 if not inserted
  @override
  Future<Id> insert(ItemT item) async {
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
    Id id = await db.insert(table, map);
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
    Id? id = item.id;
    if(!item.isValid(repository: this, logger: logger)){
      return false;
    }
    Map<String, Object?>? map = await toMap(item);
    if(map == null){
      logger.error("no db mapping for object, can not update");
      return false;
    }
    int count = await db.update(table, map, where: '$_columnIdName = ?', whereArgs: [id]);
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
    Id id = item.id!;
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
    // _logger.subModule("toMap()").error("abstract method is called");
    // return {};
    var map = <String, Object?>{};
    for(var field in allFields){
      map[field.name] = field.abstractGet(item);
    }
    return map;
  }

  Future<ItemT?> fromMap(Map map) async{
    // _logger.subModule("fromMap()").error("abstract method is called");
    var item = itemCreator();
    for(var field in relativeFields){
      await field.relativeRepository.getAll(); // create cache
      field.abstractSet(item, map[field.name]);
    }
    for(var field in simpleFields) {
      field.abstractSet(item, map[field.name]);
    }
    return item;
  }

  Future<bool> _deleteById(Id id) async {
    var logger = _logger.subModule("_deleteById()");
    int deleteCount = await db.delete(table, where: 'id = ?', whereArgs: [id]);
    if(deleteCount == 0) {
      logger.error("failed to delete in db");
      return false;
    }
    logger.info("successfully deleted");
    return true;
  }

  Future<void> _handleRelativeDelition(RelativeDbField field, Id? id) async{
    if(id == null){
      return;
    }

    if(_itemsCache != null){
      for(var item in _itemsCache!.values){
        Id? fieldId = field.abstractGet(item) as Id?;
        if(fieldId == id){
          field.abstractSet(item, null);
        }
      }
    }
    await db.execute("""
      UPDATE $table 
      SET ${field.name} = NULL
      WHERE ${field.name} = ${id};
    """);
  }

  Future<void> _callHooks(List<Hook<ItemT>> hooks, ItemT item) async{
    for(var hook in hooks){
      await hook(item);
    } 
  } 
}

//--------------------------------------------------------------------
//--------------------------------------------------------------------
// Perhaps we do not need this 

// abstract class BaseRelativesDbRepository<
//   ItemT extends RelativesRepositoryItem<ItemT, ParentT, ChildT>, ParentT extends RepositoryItem<ParentT>, ChildT extends RepositoryItem<ChildT>
//   > extends BaseDbRepository<ItemT>
//     with AbstractRelativesRepository<ItemT, ParentT, ChildT> {

//   Logger _logger = Logger("BaseRelativesDbRepository");

//   AbstractRelativesRepository<ChildT, ItemT, dynamic>? childrenRepository;
//   AbstractRelativesRepository<ParentT, dynamic, ItemT>? parentsRepository;
//   Map<Id,Map<Id,ItemT>>? _itemsByParentCache = {};

//   // returns inserted id or 0 if not inserted
//   @override
//   Future<Id> insert(ItemT item) async {
//     var id = await super.insert(item);
//     if(id != 0 ){
//       var childMap = _tryGetOrCreateChildMap(item);
//       if(childMap != null){
//         childMap[item.id!] = item;
//       } else if (item.parent != null){
//         _logger.warning("perhaps item has not valid parent");
//       }
//     }
//     return id;
//   }

//   // returns true if success
//   @override
//   Future<bool> update(ItemT item) async {
//     bool updated = await super.update(item);
//     // TODO: do nothing?
//     return updated;
//   }

//   // returns count of deleted
//   @override
//   Future<bool> delete(ItemT item) async {
//     bool deleted = await super.delete(item);
//     if(deleted){
//       setParent(item, null);
//     }
//     return deleted;
//   }

//   @override
//   Future<Map<Id,ChildT>> getChildren(ItemT item) async {
//     var logger = _logger.subModule("getChildren()");
//     if(item.isValid(repository: this, logger: logger)){
//       return {};
//     }
//     if(childrenRepository == null){
//       logger.warning("children repository is null");
//       return {};
//     }
//     return await  childrenRepository!.getItemsByParent(item);
//   }

//   @override
//   Future<Map<Id,ItemT>> getItemsByParent(ParentT parent) async{
//     var logger = _logger.subModule("getChildren()");
//     if(parent.isValid(logger: logger)){
//       return {};
//     }
//     _itemsByParentCache ??= await _getItemsByParent();
//     var result  = _itemsByParentCache![parent.id];
//     if(result != null){
//       return result;
//     }
//     return {};
//   }

//   Future<Map<Id,Map<Id,ItemT>>>  _getItemsByParent() async {
//     var allItems = await getAll();
//     Map<Id,Map<Id,ItemT>> result = {};

//     for(var item in allItems.values){
//       if(item.parent != null && item.parent!.id != null && item.id != null) {
//         var submap = result.putIfAbsent(item.parent!.id!, () => {});
//         submap[item.id!] = item;
//       }
//     }
//     return result;
//   }

//   Map<Id,ItemT>? _tryGetOrCreateChildMap(ItemT item){
//     if(_itemsByParentCache == null){
//       return null;
//     }
//     if(item.isValid(repository: this) && isValidRepositoryItem(item.parent)){
//       return _itemsByParentCache!.putIfAbsent(item.parent!.id!, () => {});
//     }
//   }

//   // internal
//   @override
//   void setParent(ItemT item, ParentT? parent) {
//     if(item.parent == parent){
//       return;
//     }
//     var childrenMapBefore = _tryGetOrCreateChildMap(item);
//     item.parent = parent;
//     var childrenMapAfter = _tryGetOrCreateChildMap(item);
//     if(childrenMapBefore != null){
//       childrenMapBefore.remove(item.id);
//     }
//     if(childrenMapAfter != null){
//       childrenMapAfter[item.id!] = item;
//     }
//   }

//   void removeParentForAll(ParentT parent){
//     if(_itemsByParentCache == null){
//       return;
//     }
//     var childMap = _itemsByParentCache![parent.id];
//     if(childMap != null){
//       for(var child in childMap.values){
//         child.parent = null;
//       }
//       _itemsByParentCache!.remove(parent.id);
//     }
//   }
// }

