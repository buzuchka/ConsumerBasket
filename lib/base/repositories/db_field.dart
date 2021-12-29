import 'package:consumer_basket/base/logger.dart';
import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/base/repositories/db_abstract_repository.dart';

abstract class AbstractField {
  String name;

  AbstractField(this.name);

  Object? abstractGet(Object item) {}
  abstractSet(Object item, Object? fieldValue) {}
}

typedef Getter<ItemT,FieldT> = FieldT Function(ItemT);
typedef Setter<ItemT,FieldT> = Function(ItemT, FieldT);

class DbField<ItemT, FieldT> extends AbstractField {

  Logger _logger = Logger(" DbField<${ItemT.toString()}, ${FieldT.toString()}>");

  String sqlType;
  Getter<ItemT,FieldT> getter;
  Setter<ItemT,FieldT> setter;

  bool index = false;
  bool unique = false;


  DbField(
      String name,
      this.sqlType,
      this.getter,
      this.setter,
      {bool? index, bool? unique}
  ): super(name){
    if(index != null){
      this.index = index;
    }
    if(unique != null){
      this.unique = unique;
      if(unique == true){
        this.index = true;
      }
    }
  }

  String? getIndexSchema(String tableName) {
    if(!index){
      return null;
    }
    String uniqueStr = "";
    if(unique){
      uniqueStr = "UNIQUE";
    } 
    return "CREATE $uniqueStr INDEX IF NOT EXISTS index_$name ON $tableName ($name);";
  }

  @override
  String toString(){
    return "$name $sqlType";
  }

  String get fieldId => "${ItemT.toString()}_$name";

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

    if(fieldValue is! FieldT){
      logger.error("fieldValue is not ${FieldT.toString()}");
      return;
    }
    setter(item as ItemT, fieldValue as FieldT);
  }
}

class RelativeDbField<
    ItemT extends AbstractRepositoryItem<ItemT>,
    FieldT extends AbstractRepositoryItem<FieldT>
> extends DbField<ItemT, int?> {

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

  void setDependentRepository(AbstractDbRepository<ItemT> repository, Hook<int?> idHook){
    relativeRepository.dependentRepositoriesByType[ItemT.toString()] =
        DependentRepositoryInfo(this, repository);
    relativeRepository.onDeleteHooks.add(
            (FieldT item) async => await idHook(item.id)
    );
  }
}