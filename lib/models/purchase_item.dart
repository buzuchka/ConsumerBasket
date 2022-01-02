import 'package:decimal/decimal.dart';
import 'package:consumer_basket/helpers/price_and_quantity.dart';
import 'package:consumer_basket/base/repositories/abstract_repository_item.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:consumer_basket/models/purchase.dart';

// Элемент в покупке (товар+цена+количество)
class PurchaseItem extends AbstractRepositoryItem<PurchaseItem> {
  Purchase? parent;
  GoodsItem? goodsItem;
  Decimal? get quantity => _quantity;
  Decimal? get totalPrice => _totalPrice;
  Decimal? get unitPrice => _unitPrice;

  set quantity (Decimal? q) {
    _quantity = normalizeQuantity(q);
    _updateTotalPrice();
  }

  set totalPrice (Decimal? price) {
    _totalPrice = normalizePrice(price);
    _updateUnitPrice();
  }

  set unitPrice (Decimal? price){
    _unitPrice = normalizePrice(price);
    _updateTotalPrice();
  }

  _updateTotalPrice(){
    if(_unitPrice == null || _quantity == null){
      _totalPrice = null;
    } else {
      _totalPrice = normalizePrice(_unitPrice! * quantity!);
    }
  }

  _updateUnitPrice(){
    if(_totalPrice == null || quantity == null){
      _unitPrice = null;
    } else {
      _unitPrice = normalizePrice((_totalPrice! / quantity!).toDecimal(
          scaleOnInfinitePrecision:priceScale));
    }
  }

  Decimal? _quantity = Decimal.one;
  Decimal? _totalPrice;
  Decimal? _unitPrice;
}