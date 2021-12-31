import 'package:consumer_basket/base/repositories/db_repository.dart';
import 'package:consumer_basket/models/shop.dart';
import 'package:consumer_basket/base/repositories/db_field.dart';

class ShopsRepository extends DbRepository<Shop> {

  ShopsRepository(){
    super.init(
        "shops",
        () => Shop(),
        [
          DbField<Shop,String?>(
              "title", "TEXT",
              (Shop item) => item.title,
              (Shop item, String? title) => item.title = title
          ),
          DbField<Shop,String?>(
              "image_path", "TEXT",
                  (Shop item) => item.imagePath,
                  (Shop item, String? imagePath) => item.imagePath = imagePath),
        ]
    );
  }
}

