import 'package:decimal/decimal.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';



class PriceDbFieldOpt<ItemT> extends DbField<ItemT,int?>{

  static const int priceDbScale = 2;

  Getter<ItemT,Decimal?> priceGetter;
  Setter<ItemT,Decimal?> priceSetter;

  PriceDbFieldOpt(
      String priceName,
      this.priceGetter,
      this.priceSetter,
      [bool? index, bool? unique]
      ):super(
    priceName,
    "INTEGER",
    (ItemT item) {
      var price = priceGetter(item);
      if(price == null){
        return null;
      }
      return price.shift(priceDbScale).round().toBigInt().toInt();
    },
    (ItemT item, int? dbPrice) {
      if(dbPrice == null){
        priceSetter(item, null);
      } else {
        priceSetter(item, Decimal.fromInt(dbPrice).shift(-priceDbScale));
      }
    },
    index: index, unique: unique
  );

}