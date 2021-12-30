import 'package:sqflite/sqflite.dart';
import 'package:consumer_basket/base/logger.dart';
import 'package:consumer_basket/base/repositories/abstract_repository.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';
import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';

typedef Hook<ItemT> = Future<void> Function(ItemT);

typedef ItemCreator<ItemT> = ItemT Function();

class DependentRepositoryInfo{
  RelativeDbField field;
  AbstractDbRepository repository;
  DependentRepositoryInfo(this.field, this.repository);
}

// Db repository main interface
// All methods are overridden in DbRepository
abstract class AbstractDbRepository<ItemT extends AbstractRepositoryItem<ItemT>>
    extends AbstractRepository<ItemT> {

  // item type as string
  @override
  String get itemType => ItemT.toString();

  // returns items as id->value (get form cache or get from db and create cache)
  @override
  Future<Map<int,ItemT>> getAll() async {
    _logger.abstractMethodError("getAll()");
    return {};
  }

  // returns items cache if it exists
  @override
  Map<int,ItemT>? getAllCache() {
    _logger.abstractMethodError("getAllCach()");
  }

  // returns true if success
  @override
  Future<bool> update(ItemT item) async {
    _logger.abstractMethodError("update()");
    return false;
  }

  // returns inserted id or 0 if not inserted
  @override
  Future<int> insert(ItemT item) async {
    _logger.abstractMethodError("insert()");
    return 0;
  }

  // returns true if deleted
  @override
  Future<bool> delete(ItemT item) async {
    _logger.abstractMethodError("delete()");
    return false;
  }

  // initialize repository (do not initialize db)
  init(
      Database db,
      String table,
      ItemCreator<ItemT> itemCreator,
      List<DbField> fields){
    _logger.abstractMethodError("init()");
  }

  // create table and indexes in db if not exists
  createIfNotExists() async {
    _logger.abstractMethodError("createIfNotExists()");
  }


  // return items by certain relative field
  Future<Map<int,ItemT>> getByRelative<FieldT extends  AbstractRepositoryItem<FieldT>>(
      RelativeDbField<ItemT,FieldT> field, FieldT relative) async {
    _logger.abstractMethodError("getByRelative()");
    return {};
  }

  // return items by certain field (even index does not exist)
  Future<Map<int,ItemT>> getByDbField<FieldT>(
      DbField<ItemT,dynamic> field, FieldT value) async{
    _logger.abstractMethodError("getByDbField()");
    return {};
  }

  // returns dependent items (from dependent repository)
  // WARNING: only one dependent by type can be resolved
  Future<Map<int, DependentT>>
  getDependents<DependentT extends AbstractRepositoryItem<DependentT>>(
      ItemT item) async {
    _logger.abstractMethodError("getDependents()");
    return {};
  }

  // returns item fields as dictionary compatible with db (db raw object)
  Future<Map<String, Object?>?> toDbMap(ItemT item) async{
    _logger.abstractMethodError("toMap()");
  }

  // converts db raw object to item
  Future<ItemT?> fromDbMap(Map map) async{
    _logger.abstractMethodError("fromDbMap()");
  }

  // db table name
  String get tableName {
    _logger.abstractMethodError("get table");
    return "_UNDEFINED_";
  }

  // hooks on insert operations
  List<Hook<ItemT>> get onInsertHooks {
    _logger.abstractMethodError("get onInsertHooks");
    return [];
  }

  // hooks on update operations
  List<Hook<ItemT>> get onUpdateHooks {
    _logger.abstractMethodError("get onUpdateHooks");
    return [];
  }

  // hooks on delete operations
  List<Hook<ItemT>> get onDeleteHooks {
    _logger.abstractMethodError("get onDeleteHooks");
    return [];
  }

  // dependent repository by its item type
  Map<String, DependentRepositoryInfo> get dependentRepositoriesByType {
    _logger.abstractMethodError("get onDeleteHooks");
    return {};
  }

  // db field by its name
  Map<String, DbField> get fieldsByName {
    _logger.abstractMethodError("get fieldsByName");
    return {};
  }

  // internal
  handleDependentInsertion<DepItemT extends AbstractRepositoryItem<DepItemT>>(DepItemT depItem) async{
    _logger.abstractMethodError("handleDependentInsertion()");
  }

  // internal
  handleDependentDeletion<DepItemT extends AbstractRepositoryItem<DepItemT>>(DepItemT depItem) async {
    _logger.abstractMethodError("handleDependentDeletion()");
  }

  // internal
  set db(Database db) {
    _logger.abstractMethodError("set db");
  }

  final Logger _logger = Logger("AbstractDbRepository<${ItemT.toString()}>");
}
