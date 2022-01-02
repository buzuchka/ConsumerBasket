import 'package:decimal/decimal.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';
import 'package:consumer_basket/helpers/price_and_quantity.dart';


class DecimalDbFieldOpt<ItemT> extends DbField<ItemT,int?>{

  int scale;
  Getter<ItemT,Decimal?> decimalGetter;
  Setter<ItemT,Decimal?> decimalSetter;

  DecimalDbFieldOpt(
      String columnName,
      this.scale,
      this.decimalGetter,
      this.decimalSetter,
      [bool? index, bool? unique]
      ):super(
      columnName,
    "INTEGER",
    (ItemT item) {
      var price = decimalGetter(item);
      return decimalToScaledInt(price,scale);
    },
    (ItemT item, int? dbPrice) {
      decimalSetter(item, scaledIntToDecimal(dbPrice,scale));
    },
    index: index, unique: unique
  );

}

class OptPriceDbField<ItemT> extends DecimalDbFieldOpt<ItemT> {

  OptPriceDbField(
      String columnName,
      Getter<ItemT,Decimal?> priceGetter,
      Setter<ItemT,Decimal?> priceSetter,
      [bool? index, bool? unique]
      ): super(columnName, priceScale, priceGetter, priceSetter, index, unique);
}

class OptQuantityDbField<ItemT> extends DecimalDbFieldOpt<ItemT> {

  OptQuantityDbField(
      String columnName,
      Getter<ItemT,Decimal?> quantityGetter,
      Setter<ItemT,Decimal?> quantitySetter,
      [bool? index, bool? unique]
      ): super(columnName, quantityScale, quantityGetter, quantitySetter, index, unique);
}