import 'package:consumer_basket/models/repository_item.dart';
import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/repositories/abstract_repository.dart';

import 'package:consumer_basket/common/logger.dart';

abstract class BaseDbRepository<ObjT extends RepositoryItem<ObjT>> extends AbstractRepository<ObjT> {
  late Database db;
  late String table;
  final Logger _logger = Logger("BaseRepository<${ObjT.toString()}>");

  static const String _columnIdName = 'id';

  @override
  Future<List<ObjT>> getAll() async {
    // _printError("getAll()", "abstract method is called");
    List<Map<String, dynamic>> rawObjs = await db.query(table);
    List<ObjT> result = [];
    for (var rawObj in rawObjs){
      ObjT? obj = fromMap(rawObj);
      if(obj == null){
        _logger.subModule("getAll()").error("fromMap() returns emty obj, skip it");
        continue;
      }
      obj.repository = this;
      obj.id = rawObj[_columnIdName] as int?;
      result.add(obj);
    }
    return result;
  }

  @override
  Future<void> update(ObjT obj) async {
    // print("Error: AbstractRepository<ObjT>::update(): abstract method is called");
    var logger = _logger.subModule("update()");
    int? id = obj.id;
    if(id == null){
      logger.error("object has no id, can not update");
      return;
    }
    Map<String, Object?> map = toMap(obj);
    if(map == null){
      logger.error("no db mapping for object, can not update");
      return;
    }
    await db.update(table, map, where: 'id = ?', whereArgs: [id]);
    logger.info("successfully updated");
  }

  @override
  Future<int> insert(ObjT obj) async {
    Map<String, Object?> map = toMap(obj);
    if (obj.id != null) {
      map[_columnIdName] = obj.id;
    }
    if(map == null){
      _logger.subModule("insert()").error("no db mapping for object, can not insert");
      return 0;
    }
    obj.repository = this;
    int id = await db.insert(table, map);
    obj.id = id;
    return id;
  }

  @override
  Future<int> delete(ObjT obj) async {
    int? id = obj.id;
    if(id == null){
      _logger.subModule("delete()").error("object has no id, can not delete");
      return 0;
    }
    return await deleteById(id);
  }

  Future<int> deleteById(int id) async {
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> toMap(ObjT obj){
    _logger.subModule("toMap()").error("abstract method is called");
    return {};
  }

  ObjT? fromMap(Map map){
    _logger.subModule("fromMap()").error("abstract method is called");
  }
}

