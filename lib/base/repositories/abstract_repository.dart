import 'package:consumer_basket/base/logger.dart';

abstract class AbstractRepository<ItemT> {
  final Logger _logger = Logger("AbstractRepository<${ItemT.toString()}>");

  String get itemType => ItemT.toString();

  // returns items as id->value (get form cache or get from db and create cache)
  Future<Map<int,ItemT>> getAll() async {
    _logger.abstractMethodError("getAll()");
    return {};
  }

  // returns items cache if it exists
  Map<int,ItemT>? getAllCache() {
    _logger.abstractMethodError("getAllCach()");
  }

  // returns true if success
  Future<bool> update(ItemT item) async {
    _logger.abstractMethodError("update()");
    return false;
  }

  // returns inserted id or 0 if not inserted
  Future<int> insert(ItemT item) async {
    _logger.abstractMethodError("insert()");
    return 0;
  }

  // returns true if deleted
  Future<bool> delete(ItemT item) async {
    _logger.abstractMethodError("delete()");
    return false;
  }

}
