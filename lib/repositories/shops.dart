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
              columnName: "title",
              sqlType: "TEXT",
              getter: (Shop item) => item.title,
              setter: (Shop item, String? title) => item.title = title
          ),
          DbField<Shop,String?>(
              columnName: "image_path",
              sqlType: "TEXT",
              getter: (Shop item) => item.imagePath,
              setter: (Shop item, String? imagePath) => item.imagePath = imagePath),
        ]
    );
  }
}

