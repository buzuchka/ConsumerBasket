import 'package:sqflite/sqflite.dart';

import 'package:consumer_basket/repositories/base_repository.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:consumer_basket/repositories/db_field.dart';

class GoodsRepository extends BaseDbRepository<GoodsItem> {

  GoodsRepository(Database db){
    super.init(
        db, "goods",
        () => GoodsItem(),
        [
          DbField<GoodsItem,String?>(
              "title", "TEXT",
                  (GoodsItem item) => item.title,
                  (GoodsItem item, String? title) => item.title = title ),
          DbField<GoodsItem,String?>(
              "image_path", "TEXT",
                  (GoodsItem item) => item.imagePath,
                  (GoodsItem item, String? imagePath) => item.imagePath = imagePath ),
        ]
    );
  }
}

