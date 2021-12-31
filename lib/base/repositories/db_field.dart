import 'package:consumer_basket/base/logger.dart';
import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/base/repositories/db_abstract_repository.dart';

abstract class AbstractField {
  Object? abstractGet(Object item) {}
  abstractSet(Object item, Object? fieldValue) {}
}

typedef Getter<ItemT,FieldT> = FieldT Function(ItemT);
typedef Setter<ItemT,FieldT> = Function(ItemT, FieldT);


class DbColumnInfo{
  late String tableName;
  late String columnName;
  late String sqlType;
  bool isIndexed = false;
  bool isUnique = false;
  String get indexName => "index_${tableName}_${columnName}";
  String get sqlColumnDef => "$columnName $sqlType";
  String get tableColumnName =>"$tableName.$columnName";

  @override
  String toString(){
    return sqlColumnDef;
  }
}

class DbField<ItemT, FieldT> extends AbstractField with DbColumnInfo {

  Logger _logger = Logger(" DbField<${ItemT.toString()}, ${FieldT.toString()}>");

  String get fieldType => FieldT.toString();

  Setter<ItemT,FieldT> setter;
  Getter<ItemT,FieldT> getter;

  // String columnName;
  // String sqlType;
  // bool isIndexed = false;
  // bool isUnique = false;

  DbField(
      columnName,
      sqlType,
      this.getter,
      this.setter,
      {bool? index, bool? unique}
  ){
    super.columnName = columnName;
    super.sqlType = sqlType;
    if(index != null){
      super.isIndexed = index;
    }
    if(unique != null){
      super.isUnique = unique;
      if(unique == true){
        super.isIndexed = true;
      }
    }
  }

  String? getIndexSchema(String tableName) {
    if(!isIndexed){
      return null;
    }
    String uniqueStr = "";
    if(isUnique){
      uniqueStr = "UNIQUE";
    } 
    return "CREATE $uniqueStr INDEX IF NOT EXISTS index_$columnName ON $tableName ($columnName);";
  }



  String get fieldId => "${ItemT.toString()}_$columnName";

  @override
  Object? abstractGet(Object item) {
    if(item is ItemT) {
      return getter(item as ItemT);
    }
  }

  @override
  abstractSet(Object item, Object? fieldValue) {
    var logger = _logger.subModule("abstractSet()");
    if( item is! ItemT){
      logger.error("item is not ${ItemT.toString()}");
      return;
    }
    if(FieldT is bool &&  fieldValue is int){
      setter(item as ItemT, (fieldValue!=0) as FieldT);
    }
    if(fieldValue is! FieldT){
      logger.error("fieldValue is not ${FieldT.toString()}");
      return;
    }
    setter(item as ItemT, fieldValue);
  }
}


typedef DepRepHook<ItemT> =
  Future<void> Function(AbstractDbRepository, ItemT);


class RelativeDbField<
    ItemT extends AbstractRepositoryItem<ItemT>,
    FieldT extends AbstractRepositoryItem<FieldT>
> extends DbField<ItemT, int?> {

  @override
  String get fieldType => FieldT.toString();

  AbstractDbRepository<FieldT> relativeRepository;

  RelativeDbField(
    String idName, 
    this.relativeRepository, 
    Getter<ItemT,FieldT?> getter, 
    Setter<ItemT,FieldT?> setter,
    {bool? index, bool? unique}
    )
      : super(
          idName, "INTEGER",
          (ItemT item) => (getter(item))?.id,
          (ItemT item, int? id) {
            var relCache = relativeRepository.getAllCache();
            if (id != null && relCache != null) {
              setter(item, relCache[id]);
            } else {
              setter(item, null);
            }
          },
          index: index,
          unique: unique
          );

  void setDependentRepository(
      AbstractDbRepository<ItemT> repository,
      Hook<int?> idHook,
      DepRepHook<ItemT> depOnInsertHook,
      DepRepHook<ItemT> depOnDeleteHook,
      ){
    relativeRepository.dependentRepositoriesByType[ItemT.toString()] =
        DependentRepositoryInfo(this, repository);
    relativeRepository.onDeleteHooks.add(
            (FieldT item) async => await idHook(item.id)
    );
    repository.onInsertHooks.add(
            (ItemT item) async => await depOnInsertHook(relativeRepository,item) // relativeRepository.handleDependentInsertion(item)
    );
    repository.onDeleteHooks.add(
            (ItemT item) async => await depOnDeleteHook(relativeRepository,item) //relativeRepository.handleDependentDeletion(item)
    );
  }
}

class DependentDbField<
    ItemT extends AbstractRepositoryItem<ItemT>,
    FieldT extends AbstractRepositoryItem<FieldT>
> extends AbstractField {

  String get fieldType => FieldT.toString();

  Logger _logger = Logger("DependentDbField<${ItemT.toString()},${FieldT.toString()}>");

  Getter<ItemT,Map<int,FieldT>> getter;

  DependentDbField(this.getter);

  set(ItemT item, AbstractDbRepository<ItemT> rep) async {
    var depItemMap = getter(item);
    await rep.getDependents<FieldT>(item);
    depItemMap.clear();
    depItemMap.addAll(depItemMap);
  }

  onInsert(ItemT item, FieldT depItem){
    var logger = _logger.subModule("onInsert()");
    if(!depItem.isValid(logger: logger)){
      return;
    }
    var depItemMap = getter(item);
    depItemMap[depItem.id!] = depItem;
  }

  onDelete(ItemT item, FieldT depItem) {
    var logger = _logger.subModule("onDelete()");
    if(!depItem.isValid(logger: logger)){
      return;
    }
    var depItemMap = getter(item);
    depItemMap.remove(depItem.id);
  }

}