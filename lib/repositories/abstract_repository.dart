import 'package:consumer_basket/common/logger.dart';

abstract class AbstractRepository<ObjT> {
  final Logger _logger = Logger("AbstractRepository<${ObjT.toString()}>");


  // returns items cache as id->value
  Future<Map<int,ObjT>> getAll() async {
    _logger.abstractMethodError("getAll()");
    return {};
  }

  // returns true if success
  Future<bool> update(ObjT obj) async {
    _logger.abstractMethodError("update()");
    return false;
  }

  // returns inserted id or 0 if not inserted
  Future<int> insert(ObjT obj) async {
    _logger.abstractMethodError("insert()");
    return 0;
  }

  // returns count of deleted
  Future<int> delete(ObjT obj) async {
    _logger.abstractMethodError("delete()");
    return 0;
  }

}


abstract class AbstractRelativesRepository<ItemT, ParentT, ChildT> {

  final Logger _aLogger = Logger("AbstractRelativesRepository<${ItemT.toString()},${ChildT.toString()}>");

  Future<Map<int,ChildT>> getChildren(ItemT item) async {
    _aLogger.abstractMethodError("getChildren()");
    return {};
  }

  Future<Map<int,ItemT>> getItemsByParent(ParentT parent) async{
    _aLogger.abstractMethodError("getItemsByParent()");
    return {};
  }
}