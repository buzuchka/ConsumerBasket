import 'package:consumer_basket/models/repository_item.dart';

class GoodsItem extends RepositoryItem<GoodsItem> {

  int? id;
  String? title;
  String? imagePath;

  GoodsItem();

  GoodsItem.Full(this.id, this.title, this.imagePath);

  GoodsItem.Short(String _title){
    title = _title;
  }
}
