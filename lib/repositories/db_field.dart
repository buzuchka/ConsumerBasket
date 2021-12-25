import 'package:consumer_basket/common/logger.dart';
import 'package:consumer_basket/models/repository_item.dart';
import 'package:consumer_basket/repositories/abstract_repository.dart';

abstract class AbstractDbField {
  late String name;
  late String sqlType;

  Object? abstractGet(Object item) {
  }

  abstractSet(Object item, Object fieldValue) {
  }
}

typedef Getter<ItemT,FieldT> = FieldT Function(ItemT);
typedef Setter<ItemT,FieldT> = Function(ItemT, FieldT);

class DbField<ItemT, FieldT> extends AbstractDbField {

  Logger _logger = Logger(" DbField<${ItemT.toString()}, ${FieldT.toString()}>");

  Getter<ItemT,FieldT> getter;
  Setter<ItemT,FieldT> setter;

  DbField(String name, String sqlType, this.getter, this.setter){
    super.name = name;
    super.sqlType = sqlType;
  }

  @override
  String toString(){
    return "$name $sqlType";
  }

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


class RelativeDbField<ItemT,  FieldT extends RepositoryItem<FieldT>> extends DbField<ItemT, int?> {

  AbstractRepository<FieldT> relativeRepository;

  RelativeDbField(String name, this.relativeRepository, Getter<ItemT,FieldT?> getter, Setter<ItemT,FieldT?> setter)
      : super(
          name, "INTEGER",
          (ItemT item) => (getter(item))?.id,
          (ItemT item, int? id) {
            var relCache = relativeRepository.getAllCache();
            if (id != null && relCache != null) {
              setter(item, relCache[id]);
            } else {
              setter(item, null);
            }
          }
          );
}