import 'package:consumer_basket/common/logger.dart';
import 'package:consumer_basket/models/repository_item.dart';
import 'package:consumer_basket/repositories/abstract_repository.dart';
import 'package:consumer_basket/repositories/base_repository.dart';

abstract class AbstractField {
  String name;

  AbstractField(this.name);

  Object? abstractGet(Object item) {
  }

  abstractSet(Object item, Object? fieldValue) {
  }
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


  DbField(String name, this.sqlType , this.getter, this.setter, {bool? index, bool? unique}): super(name){
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

  // abstractSet(Object item, Object? fieldValue) => setter(item as ItemT, fieldValue as FieldT);
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



class RelativeDbField<ItemT extends RepositoryItem<ItemT>,  FieldT extends RepositoryItem<FieldT>> extends DbField<ItemT, int?> {

  BaseDbRepository<FieldT> relativeRepository;

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

  void setDependentRepository(BaseDbRepository<ItemT> repository){

    relativeRepository.dependentRepositortiesByType[ItemT.toString()] =
        DependentRepositoryInfo(this, repository);

    relativeRepository.onDeleteHooks.add(
            (FieldT item) async => await repository.handleRelativeDelition(this, item.id)
    );
  }

  void _addHookOnDelete(Hook<int?> hookWithId){

  }

}