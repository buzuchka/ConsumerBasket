import 'package:consumer_basket/models/repository_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/repositories/abstract_repository.dart';
import 'package:consumer_basket/common/logger.dart';

abstract class BaseDbRepository<ObjT extends RepositoryItem<ObjT>> extends AbstractRepository<ObjT> {
  late Database db;
  late String table;
  late String schema;

  final Logger _logger = Logger("BaseRepository<${ObjT.toString()}>");
  Map<int,ObjT>? _itemsCache;

  static const String _columnIdName = 'id';

  createIfNotExists() async{
    db.execute("""
      CREATE TABLE IF NOT EXISTS $table (
        id INTEGER PRIMARY KEY NOT NULL,
        $schema
      )
    """);
  }

  // returns items cache
  @override
  Future<Map<int,ObjT>> getAll() async {
    if(_itemsCache != null){
      return _itemsCache!;
    }
    _itemsCache = <int,ObjT>{};
    List<Map<String, dynamic>> raw_objs = await db.query(table);
    for (var raw_obj in raw_objs){
      ObjT? obj = await fromMap(raw_obj);
      if(obj == null){
        _logger.subModule("getAll()").error("fromMap() returns emty obj, skip it");
        continue;
      }
      obj.repository = this;
      int id = raw_obj[_columnIdName] as int;
      obj.id = id;
      _itemsCache![id] = obj;
    }
    return _itemsCache!;
  }

  // returns true if success
  @override
  Future<bool> update(ObjT obj) async {
    var logger = _logger.subModule("update()");
    int? id = obj.id;
    if(id == null){
      logger.error("object has no id, can not update");
      return false;
    }
    Map<String, Object?>? map = await toMap(obj);
    if(map == null){
      logger.error("no db mapping for object, can not update");
      return false;
    }
    await db.update(table, map, where: 'id = ?', whereArgs: [id]);
    logger.info("successfully updated");
    return true;
  }

  // returns inserted id or 0 if not inserted
  @override
  Future<int> insert(ObjT obj) async {
    var logger = _logger.subModule("insert()");
    Map<String, Object?>? map = await toMap(obj);
    if(map == null){
      logger.error("no db mapping for object, can not insert");
      return 0;
    }
    if (obj.id != null) {
      map[_columnIdName] = obj.id;
    }
    obj.repository = this;
    int id = await db.insert(table, map);
    obj.id = id;
    if(_itemsCache != null && id != 0){
      _itemsCache![id] = obj;
    }
    return id;
  }

  // returns count of deleted
  @override
  Future<int> delete(ObjT obj) async {
    int? id = obj.id;
    if(id == null){
      _logger.subModule("delete()").error("object has no id, can not delete");
      return 0;
    }
    int deleteCount = await deleteById(id);
    if(_itemsCache != null && deleteCount != 0){
      _itemsCache!.remove(id);
    }
    return deleteCount;
  }

  Future<int> deleteById(int id) async {
    int deleteCount = await db.delete(table, where: 'id = ?', whereArgs: [id]);
    if(deleteCount == 0) {
      _logger.subModule("deleteById()").error("failed to delete");
    }
    return deleteCount;
  }

  Future<Map<String, Object?>?> toMap(ObjT obj) async{
    _logger.subModule("toMap()").error("abstract method is called");
    return {};
  }

  Future<ObjT?> fromMap(Map map) async{
    _logger.subModule("fromMap()").error("abstract method is called");
  }
}

abstract class BaseRelativesDbRepository<
  ItemT extends RelativesRepositoryItem<ItemT, ParentT, ChildT>, ParentT extends RepositoryItem<ParentT>, ChildT extends RepositoryItem<ChildT>
  > extends BaseDbRepository<ItemT>
    with AbstractRelativesRepository<ItemT, ParentT, ChildT> {

  Logger _logger = Logger("BaseParentsDbRepository<${ItemT.toString()},${ChildT.toString()}>");

  AbstractRelativesRepository<ChildT, ItemT, dynamic>? childrenRepository;
  AbstractRelativesRepository<ParentT, dynamic, ItemT>? parentsRepository;
  Map<int,Map<int,ItemT>>? _itemsByParentCache = {};

  @override
  Future<Map<int,ChildT>> getChildren(ItemT item) async {
    var logger = _logger.subModule("getChildren");
    if(item.id == null){
      logger.warning("item id is null");
      return {};
    }
    if(childrenRepository == null){
      logger.warning("children repository is null");
      return {};
    }
    return await  childrenRepository!.getItemsByParent(item);
  }

  @override
  Future<Map<int,ItemT>> getItemsByParent(ParentT parent) async{
    if(parent.id == null){
      return {};
    }

    _itemsByParentCache ??= await _getItemsByParent();

    var result  = _itemsByParentCache![parent.id];
    if(result != null){
      return result;
    }
    return {};
  }

  Future<Map<int,Map<int,ItemT>>>  _getItemsByParent() async {
    var allItems = await getAll();
    Map<int,Map<int,ItemT>> result = {};

    for(var item in allItems.values){
      if(item.parent != null && item.parent!.id != null && item.id != null) {
        var submap = result.putIfAbsent(item.parent!.id!, () => {});
        submap[item.id!] = item;
      }
    }
    return result;
  }


}

