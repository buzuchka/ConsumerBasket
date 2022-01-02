import 'package:consumer_basket/helpers/logger.dart';
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
  String get fieldId => "${ItemT.toString()}_$columnName";

  Setter<ItemT,FieldT> setter;
  Getter<ItemT,FieldT> getter;

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
      DepRepHook<ItemT> depOnCacheInsertHook,
      DepRepHook<ItemT> depOnCacheDeleteHook,
      DepRepHook<ItemT> depOnCacheUpdateHook,
      ){
    relativeRepository.dependentRepositoriesByType[ItemT.toString()] =
        DependentRepositoryInfo(this, repository);
    relativeRepository.onDeleteHooks.add(
            (FieldT item) async => await idHook(item.id)
    );
    repository.onCacheInsertHooks.add(
            (ItemT item) async => await depOnCacheInsertHook(relativeRepository,item)
    );
    repository.onCacheDeleteHooks.add(
            (ItemT item) async => await depOnCacheDeleteHook(relativeRepository,item)
    );
    repository.onCacheUpdateHooks.add(
            (ItemT item) async => await depOnCacheUpdateHook(relativeRepository,item)
    );
  }
}


typedef DependentHook<ItemT extends AbstractRepositoryItem<ItemT>, DepItemT extends AbstractRepositoryItem<DepItemT>> =
    Function(ItemT, DepItemT);

class DependnentDbField<
    ItemT extends AbstractRepositoryItem<ItemT>,
    DepFieldT extends AbstractRepositoryItem<FieldT>
> extends AbstractField {

  String get fieldType => DepFieldT.toString();

  DependentHook<ItemT, DepFieldT>? onCacheInsert;
  DependentHook<ItemT, DepFieldT>? onCaheDelete;
  DependentHook<ItemT, DepFieldT>? onCacheUpdate;

  DependnentDbField({
    this.onCacheInsert,
    this.onCaheDelete,
    this.onCacheUpdate,
  });

  // Logger _logger = Logger("DependnentDbField<${ItemT.toString()},${FieldT.toString()}>");
}


class DependentMapDbField<
    ItemT extends AbstractRepositoryItem<ItemT>,
    DepFieldT extends AbstractRepositoryItem<DepFieldT>
> extends DependnentDbField<ItemT,DepFieldT> {
  Getter<ItemT,Map<int,DepFieldT>> depMapGetter;
  late Getter<DepFieldT, dynamic> depKeyGetter;

  DependentMapDbField({
    @required this.depMapGetter, 
    Getter<DepFieldT, dynamic>? depKeyGetter}):super(
    onInsert: (ItemT item, DepFieldT depItem) => _onInsert(depItem),
    onDelete: (ItemT item, DepFieldT depItem) => _onDelete(depItem),
    onUpdate: (ItemT item, DepFieldT depItem) {
      if(depKeyGetter != null){
        this.depKeyGetter = depKeyGetter;
      } else {
        this.depKeyGetter = (DepFieldT depField) => depField.id!;
      }
    }
    );

  _onInsert(ItemT item, DepFieldT depItem){
    var depItemMap = depMapGetter(item);
    depItemMap[depKeyGetter(depItem)] = depItem;
  }

  _onDelete(ItemT item, DepFieldT depItem) {
    var depItemMap = depMapGetter(item);
    depItemMap.remove(depKeyGetter(depItem));
  }

}