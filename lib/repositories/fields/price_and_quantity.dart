import 'package:decimal/decimal.dart';

import 'package:consumer_basket/base/repositories/db_field.dart';
import 'package:consumer_basket/helpers/price_and_quantity.dart';


class DecimalDbFieldOpt<ItemT> extends DbField<ItemT,int?>{


  DecimalDbFieldOpt({
        required String columnName,
        required scale,
        required Getter<ItemT,Decimal?> getter,
        required Setter<ItemT,Decimal?> setter,
        bool? index,
        bool? unique
      }):
        super(
          columnName: columnName,
          sqlType: "INTEGER",
          getter: (ItemT item) {
            var price = getter(item);
            return decimalToScaledInt(price,scale);
          },
          setter: (ItemT item, int? dbPrice) {
            setter(item, scaledIntToDecimal(dbPrice,scale));
          },
          index: index,
          unique: unique,
      );

}

class OptPriceDbField<ItemT> extends DecimalDbFieldOpt<ItemT> {

  OptPriceDbField({
        required String columnName,
        required Getter<ItemT,Decimal?> getter,
        required Setter<ItemT,Decimal?> setter,
        bool? index,
        bool? unique
      }):
        super(
          columnName:columnName,
          scale: priceScale,
          getter: getter,
          setter: setter,
          index:index,
          unique: unique
      );
}

class OptQuantityDbField<ItemT> extends DecimalDbFieldOpt<ItemT> {

  OptQuantityDbField({
        required String columnName,
        required Getter<ItemT,Decimal?> getter,
        required Setter<ItemT,Decimal?> setter,
        bool? index,
        bool? unique
      }): super(
            columnName: columnName,
            scale: quantityScale,
            getter: getter,
            setter: setter,
            index: index,
            unique: unique
      );
}