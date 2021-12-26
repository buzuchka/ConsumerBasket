import 'package:consumer_basket/common/logger.dart';
import 'package:consumer_basket/models/repository_item.dart';
import 'package:consumer_basket/repositories/abstract_repository.dart';

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
    String unique_str = "";
    if(unique){
      unique_str = "UNIQUE";
    } 
    return "CREATE $unique_str INDEX IF NOT EXISTS index_$name ON $tableName ($name);";
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


typedef Hook<ItemT> = Future<void> Function(ItemT); 
class RelativeDbField<ItemT,  FieldT extends RepositoryItem<FieldT>> extends DbField<ItemT, int?> {

  AbstractRepository<FieldT> relativeRepository;

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

  Hook<FieldT> idHookToFieldHook(Hook<int?> hook){
    return (FieldT item){await hook(item.id);}; 
  }


}