import 'package:sqflite/sqflite.dart';

import 'package:consumer_basket/repositories/base_repository.dart';
import 'package:consumer_basket/models/shop.dart';
import 'package:consumer_basket/repositories/db_field.dart';

class ShopsRepository extends BaseDbRepository<Shop> {

  ShopsRepository(Database db){
    super.init(
        db, "shops",
        () => Shop(),
        [
          DbField<Shop,String?>(
              "title", "TEXT",
              (Shop item) => item.title,
              (Shop item, String? title) => item.title = title//,
              //unique: true
          )
        ]
    );
  }
}

