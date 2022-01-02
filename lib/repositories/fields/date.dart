import 'package:consumer_basket/base/repositories/db_field.dart';


class DatetimeDbField<ItemT> extends DbField<ItemT,String> {

  DatetimeDbField({
      required String columnName,
      required Getter<ItemT,DateTime> getter,
      required Setter<ItemT,DateTime> setter,
      bool? index,
      bool? unique
      }): super(
        columnName: columnName,
        sqlType: "DATETIME",
        getter: (item) => getter(item).toString(),
        setter: (item, date) => setter(item, DateTime.parse(date))
      );

}