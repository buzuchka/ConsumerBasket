import 'package:consumer_basket/core/base/repositories/db_field.dart';
import 'package:consumer_basket/core/base/repositories/db_repository.dart';
import 'package:consumer_basket/core/models/goods.dart';
import 'package:consumer_basket/core/models/purchase_item.dart';
import 'package:consumer_basket/core/models/purchase.dart';

class GoodsRepository extends DbRepository<GoodsItem> {

  GoodsRepository(){
    super.init(
        "goods",
        () => GoodsItem(),
        [
          DbField<GoodsItem,String?>(
              columnName: "title",
              sqlType: "TEXT",
              getter: (GoodsItem item) => item.title,
              setter: (GoodsItem item, String? title) => item.title = title ),
          DbField<GoodsItem,String?>(
              columnName: "image_path",
              sqlType: "TEXT",
              getter: (GoodsItem item) => item.imagePath,
              setter: (GoodsItem item, String? imagePath) => item.imagePath = imagePath),
          DbField<GoodsItem,String?>(
              columnName: "note",
              sqlType: "TEXT",
              getter: (GoodsItem item) => item.note,
              setter: (GoodsItem item, String? note) => item.note = note),
          DependentMapField<GoodsItem,PurchaseItem>(
              mapGetter: (GoodsItem goodsItem) => goodsItem.purchases,
          ),
          DependentField<GoodsItem, PurchaseItem>(
              onCacheInsert: (GoodsItem goodsItem, PurchaseItem purchaseItem) => _updateLastPriceByOne(goodsItem, purchaseItem),
              onCacheDelete: (GoodsItem goodsItem, PurchaseItem purchaseItem) {
                if(goodsItem.lastPurchase == purchaseItem){
                  _selfUpdateLastPrice(goodsItem);
                }
              },
              onCacheUpdate: (GoodsItem goodsItem, PurchaseItem purchaseItem) {
                if(goodsItem.lastPurchase == purchaseItem ){
                  if(purchaseItem.date != goodsItem.lastPurchaseDate) {
                    _selfUpdateLastPrice(goodsItem);
                  }
                } else {
                  _updateLastPriceByOne(goodsItem, purchaseItem);
                }
              }
          ),
          SubscribedField<Purchase>(
              onCacheUpdate: (Purchase purchase) async => _onPurchaseUpdate(purchase)
          )
        ]
    );
  }

  static _onPurchaseUpdate(Purchase purchase){
    for(var item in purchase.items.values){
      if(item.goodsItem != null) {
        _updateLastPriceByOne(item.goodsItem!, item);
      }
    }
  }

  static _selfUpdateLastPrice(GoodsItem goodsItem){
    goodsItem.lastPurchase = null;
    for(var purchItem in goodsItem.purchases.values){
      _updateLastPriceByOne(goodsItem, purchItem);
    }
  }

  static _updateLastPriceByOne(GoodsItem goodsItem, PurchaseItem purchaseItem){
    if(purchaseItem.unitPrice == null){
      return;
    }
    if( goodsItem.lastPurchaseDate == null ||
        (purchaseItem.date != null && purchaseItem.date!.isAfter(goodsItem.lastPurchaseDate!) )
    ){
      goodsItem.lastPurchase = purchaseItem;
    }
  }

}

