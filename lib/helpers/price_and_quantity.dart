import 'package:decimal/decimal.dart';

import 'package:consumer_basket/helpers/constants.dart';

const int priceScale = 2;
const int quantityScale = 3;

Decimal? scaledIntToDecimal(int? value, int scale){
  if(value == null){
    return null;
  }
  return  Decimal.fromInt(value).shift(-scale);
}

int? decimalToScaledInt(Decimal? value, int scale) {
  if(value == null){
    return null;
  }
  return value.shift(scale).round().toBigInt().toInt();
}

int? priceToScaledInt(Decimal? price){
  return decimalToScaledInt(price, priceScale);
}

Decimal? priceFromScaledInt(int? price){
  return scaledIntToDecimal(price, priceScale);
}

Decimal? normalizePrice(Decimal? price){
  return priceFromScaledInt(priceToScaledInt(price));
}

int? quantityToScaledInt(Decimal? quantity){
  return decimalToScaledInt(quantity, quantityScale);
}

Decimal? quantityFromScaledInt(int? quantity){
  return scaledIntToDecimal(quantity, quantityScale);
}

Decimal? normalizeQuantity(Decimal? quantity){
  return quantityFromScaledInt(quantityToScaledInt(quantity));
}

String makePriceString(Decimal? price) {
  if(price == null){
    return "?";
  }
  return ("$price${Constants.currentCurrencyString}");
}

String makeQuantityString(Decimal? quantity) {
  if(quantity == null){
    return "?";
  }
  return quantity.toString();
}

String makePriceQuantityString(Decimal? price, Decimal? quantity){
  return "${makePriceString(price)} x ${makeQuantityString(quantity)}";
}

String makeTotalPriceString(Decimal? totalPrice, {bool isApproximated = false}){
  String signStr= isApproximated ? "≈" : "=";
  String totalPriceStr = (totalPrice == null) ? "?" : makePriceString(totalPrice);
  return "$signStr$totalPriceStr";
}