import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/repositories/abstract_repository.dart';

abstract class BaseDbRepository<ObjT> extends AbstractRepository<ObjT> {
  late Database db;
  late String table;
  final String _myType = "BaseRepository<${ObjT.toString()}>";

  @override
  Future<List<ObjT>> getAll() async {
    // _printError("getAll()", "abstract method is called");
    List<Map<String, dynamic>> raw_objs = await db.query(table);
    List<ObjT> result = [];
    for (var raw_obj in raw_objs){
      ObjT? obj = fromMap(raw_obj);
      if(obj == null){
        _printError("getAll()", "fromMap() returns emty obj, skip it");
        continue;
      }
      result.add(obj);
    }
    return result;
  }

  @override
  Future<void> update(ObjT obj) async {
    // print("Error: AbstractRepository<ObjT>::update(): abstract method is called");
    dynamic id = getId(obj);
    if(id == null){
      _printError("update()", "object has no id, can not update");
      return;
    }
    Map<String, Object?> map = toMap(obj);
    if(map == null){
      _printError("update()", "no db mapping for object, can not update");
      return;
    }
    await db.update(table, map, where: 'id = ?', whereArgs: [id]);
  }

  @override
  Future<int> insert(ObjT obj) async {
    Map<String, Object?> map = toMap(obj);
    if(map == null){
      _printError("insert()", "no db mapping for object, can not insert");
      return 0;
    }
    return await db.insert(table, map);
  }

  @override
  Future<int> delete(ObjT obj) async {
    String? id = getId(obj);
    if(id == null){
      _printError("delete()", "object has no id, can not delete");
      return 0;
    }
    return await deleteById(id);
  }

  Future<int> deleteById(String id) async {
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Map<String, Object?> toMap(ObjT obj){
    _printError("toMap()", "abstract method is called");
    return {};
  }

  ObjT? fromMap(Map map){
    _printError("fromMap()", "abstract method is called");
  }

  dynamic getId(ObjT obj){
    _printError("getId()", "abstract method is called");
  }

  void _printError(String place, String error_message){
    print("Error: $_myType::$place: $error_message");
  }
}

