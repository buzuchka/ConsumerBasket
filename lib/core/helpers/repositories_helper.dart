import 'package:consumer_basket/core/base/repositories/db_repository_supervisor.dart';
import 'package:consumer_basket/core/helpers/logger.dart';
import 'package:consumer_basket/core/models/goods.dart';
import 'package:consumer_basket/core/models/shop.dart';
import 'package:consumer_basket/core/models/purchase.dart';
import 'package:consumer_basket/core/models/purchase_item.dart';
import 'package:consumer_basket/core/repositories/goods.dart';
import 'package:consumer_basket/core/repositories/purchases.dart';
import 'package:consumer_basket/core/repositories/purchase_templates.dart';
import 'package:consumer_basket/core/repositories/purchase_items.dart';
import 'package:consumer_basket/core/repositories/purchase_template_items.dart';
import 'package:consumer_basket/core/repositories/shops.dart';
import 'package:consumer_basket/core/helpers/testing.dart';
import 'package:consumer_basket/core/helpers/price_and_quantity.dart';


abstract class RepositoriesHelper {

  static const String databaseName = 'CustomerBasket';

  static var goodsRepository = GoodsRepository();
  static var shopsRepository = ShopsRepository();
  static var purchasesRepository = PurchasesRepository();
  static var purchaseItemsRepository = PurchaseItemsRepository();
  static var purchaseTemplatesRepository = PurchaseTemplatesRepository();
  static var purchaseTemplateItemsRepository = PurchaseTemplateItemsRepository();

  static DbRepositorySupervisor dbRepositorySupervisor = DbRepositorySupervisor(
      [
        goodsRepository,
        shopsRepository,
        purchasesRepository,
        purchaseItemsRepository,
        purchaseTemplatesRepository,
        purchaseTemplateItemsRepository,
      ]);

  static Future<void> init() async {
    var logger = Logger("RepositoriesHelper").subModule("init()");
    try {
      logger.info("start");
      await dbRepositorySupervisor.openDatabase(databaseName);
      logger.info("finish");
    }
    catch (ex) {
      logger.error("Initialization failed: $ex");
    }

    // await deleteAllData();
    // await addTestingData();
  }

  static deleteAllData() async {
    await goodsRepository.deleteAll();
    await shopsRepository.deleteAll();
    await purchasesRepository.deleteAll();
    await purchaseItemsRepository.deleteAll();
    await purchaseTemplatesRepository.deleteAll();
    await purchaseTemplateItemsRepository.deleteAll();
  }

  static addTestingData() async {

    int goodsCount = 1000;
    int shopsCount = 100;
    int purchasesCount = 500;
    int minPurchaseItemsCount = 2;
    int maxPurchaseItemsCount = 10;
    int minQuantityUnits = 10;
    int maxQuantityUnits = 10000;
    int minPriceUnits = 10;
    int maxPriceUnits = 2000;

    var allShops = await shopsRepository.getAll();
    var allGoods = await goodsRepository.getAll();

    var goodsNames = generateGoodsNames(goodsCount).toList(growable: false);
    var shopNames = generateShopNames(shopsCount).toList(growable: false);
    goodsNames.shuffle();
    shopNames.shuffle();

    for(var goodsName in goodsNames){
      var goods = GoodsItem();
      goods.title = goodsName;
      goods.note = "Some notes about $goodsName";
      await goodsRepository.insert(goods);
    }

    for(var shopName in shopNames){
      var shop = Shop();
      shop.title = shopName;
      await shopsRepository.insert(shop);
    }

    var purchasesShops = generateRandomSequence(allShops.values.toList(), purchasesCount);

    for(var shop in purchasesShops) {
      var purchase = Purchase();
      purchase.shop = shop;
      await purchasesRepository.insert(purchase);

      var purchaseGoods = generateRandomSequence(
          allGoods.values.toList(), minPurchaseItemsCount, maxPurchaseItemsCount);

      for(var purchaseGoodsItem in purchaseGoods) {
        var item = PurchaseItem();
        item.parent = purchase;
        item.goodsItem = purchaseGoodsItem;
        item.quantity = quantityFromScaledInt(getRandomInt(minQuantityUnits,maxQuantityUnits));
        item.unitPrice = priceFromScaledInt(getRandomInt(minPriceUnits, maxPriceUnits));
        await purchaseItemsRepository.insert(item);
      }
    }

  }




}
