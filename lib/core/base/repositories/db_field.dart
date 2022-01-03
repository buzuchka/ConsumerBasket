import 'package:consumer_basket/core/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/core/base/repositories/db_abstract_repository.dart';
import 'package:consumer_basket/core/base/repositories/db_repository_supervisor.dart';
import 'package:consumer_basket/core/helpers/logger.dart';

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
      {
        required columnName,
        required sqlType,
        required this.getter,
        required this.setter,
        bool? index,
        bool? unique
      }
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
    var logger = _logger.subModule("abstractGet()");
    if( item is! ItemT){
      logger.error("item is not ${ItemT.toString()}");
      return null;
    }
    return getter(item as ItemT);
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

  late AbstractDbRepository<FieldT> relativeRepository;

  late Getter<ItemT,FieldT?> relativeGetter;
  late Setter<ItemT,FieldT?> relativeSetter;

  RelativeDbField(
      {
        required String relativeIdColumnName,
        required Getter<ItemT,FieldT?> getter,
        required Setter<ItemT,FieldT?> setter,
        bool? index,
        bool? unique,
      }
    )
      : super(
          columnName: relativeIdColumnName,
          sqlType: "INTEGER",
          getter: (item) => null,
          setter: (item, fieldVal) {},
          index: index,
          unique: unique
          ){
    relativeGetter = getter;
    relativeSetter = setter;
  }

  void resolveDependencies(
      AbstractDbRepository<ItemT> myRepository,
      DbRepositorySupervisor repositorySupervisor,
      Hook<int?> onRelativeDelete,
      DepRepHook<ItemT> depOnCacheInsertHook,
      DepRepHook<ItemT> depOnCacheDeleteHook,
      DepRepHook<ItemT> depOnCacheUpdateHook,
      ){
    relativeRepository = repositorySupervisor.getRepositoryByType<FieldT>()!;

    super.getter = (ItemT item) => (relativeGetter(item))?.id;
    super.setter = (ItemT item, int? id) {
        var relCache = relativeRepository.getAllCache();
        if (id != null && relCache != null) {
          relativeSetter(item, relCache[id]);
        } else {
          relativeSetter(item, null);
        }
    };

    relativeRepository.dependentRepositoriesByType[ItemT.toString()] =
        DependentRepositoryInfo(this, myRepository);
    relativeRepository.onDeleteHooks.add(
            (FieldT item) async => await onRelativeDelete(item.id)
    );
    myRepository.onCacheInsertHooks.add(
            (ItemT item) async => await depOnCacheInsertHook(relativeRepository,item)
    );
    myRepository.onCacheDeleteHooks.add(
            (ItemT item) async => await depOnCacheDeleteHook(relativeRepository,item)
    );
    myRepository.onCacheUpdateHooks.add(
            (ItemT item) async => await depOnCacheUpdateHook(relativeRepository,item)
    );
  }
}


typedef DependentHook<ItemT extends AbstractRepositoryItem<ItemT>, DepItemT extends AbstractRepositoryItem<DepItemT>> =
    Function(ItemT, DepItemT);


class SubscribedField<
     FieldT extends AbstractRepositoryItem<FieldT>
> extends AbstractField {

  String get fieldType => FieldT.toString();

  Hook<FieldT>? onCacheInsert;
  Hook<FieldT>? onCacheDelete;
  Hook<FieldT>? onCacheUpdate;

  SubscribedField({
    this.onCacheInsert,
    this.onCacheDelete,
    this.onCacheUpdate,
  });

  subscribe(AbstractDbRepository<FieldT> repository){
    if(onCacheInsert != null) {
      repository.onCacheInsertHooks.add(
              (FieldT item) => onCacheInsert!(item));
    }
    if(onCacheDelete != null) {
      repository.onCacheDeleteHooks.add(
              (FieldT item) => onCacheDelete!(item));
    }
    if(onCacheUpdate != null) {
      repository.onCacheUpdateHooks.add(
              (FieldT item) => onCacheUpdate!(item));
    }
  }
}


class DependentField<
    ItemT extends AbstractRepositoryItem<ItemT>,
    DepFieldT extends AbstractRepositoryItem<DepFieldT>
> extends AbstractField {

  String get fieldType => DepFieldT.toString();

  DependentHook<ItemT, DepFieldT>? onCacheInsert;
  DependentHook<ItemT, DepFieldT>? onCacheDelete;
  DependentHook<ItemT, DepFieldT>? onCacheUpdate;

  DependentField({
    this.onCacheInsert,
    this.onCacheDelete,
    this.onCacheUpdate,
  });

}


class DependentMapField<
    ItemT extends AbstractRepositoryItem<ItemT>,
    DepFieldT extends AbstractRepositoryItem<DepFieldT>
> extends DependentField<ItemT,DepFieldT> {


  DependentMapField({
      required Getter<ItemT,Map<dynamic,DepFieldT>> mapGetter,
      Getter<DepFieldT, dynamic>? keyGetter
  }):super(
      onCacheInsert: (ItemT item, DepFieldT depItem) {
        var logger = Logger("DependentMapDbField<${ItemT.toString()},${DepFieldT.toString()}>");
        logger.info("cache insert");
        var key = getKeyOrId(keyGetter,depItem);
        logger.debug("key = $key (${key.runtimeType})");
        var depItemMap = mapGetter(item);
        depItemMap[getKeyOrId(keyGetter,depItem)] = depItem;
        logger.debug("depItemMap.len = ${depItemMap.length}");
      },
      onCacheDelete: (ItemT item, DepFieldT depItem) {
        var logger = Logger("DependentMapDbField<${ItemT.toString()},${DepFieldT.toString()}>");
        logger.info("cache delete");
        var depItemMap = mapGetter(item);
        depItemMap.remove(getKeyOrId(keyGetter,depItem));
      },
      onCacheUpdate: (ItemT item, DepFieldT depItem) {});

  static getKeyOrId<DepFieldT extends AbstractRepositoryItem<DepFieldT>>(
      Getter<DepFieldT, dynamic>? depKeyGetter, DepFieldT depFieldValue
      ){
    if(depKeyGetter != null){
      return depKeyGetter(depFieldValue);
    }
    return depFieldValue.id;
  }
}