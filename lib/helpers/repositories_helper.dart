import 'package:consumer_basket/helpers/logger.dart';
import 'package:consumer_basket/base/repositories/db_repository_supervisor.dart';
import 'package:consumer_basket/repositories/goods.dart';
import 'package:consumer_basket/repositories/purchases.dart';
import 'package:consumer_basket/repositories/purchase_templates.dart';
import 'package:consumer_basket/repositories/purchase_items.dart';
import 'package:consumer_basket/repositories/purchase_template_items.dart';
import 'package:consumer_basket/repositories/shops.dart';

abstract class RepositoriesHelper {

  static const String databaseName = 'CustomerBasket';

  static var goodsRepository = GoodsRepository();
  static var shopsRepository = ShopsRepository();
  static var purchasesRepository = PurchasesRepository();
  static var purchaseItemsRepository = PurchaseItemsRepository();
  static var purchaseTemplatesRepository = PurchaseTemplatesRepository();
  static var purchaseTemplateItemsRepository = PurchaseTemplateItemsRepository();

  static DbRepositorySupervisor dbRepositorySupervisor = DbRepositorySupervisor([
    goodsRepository,
    shopsRepository,
    purchasesRepository,
    purchaseItemsRepository,
    purchaseTemplatesRepository,
    purchaseTemplateItemsRepository,
  ]);

  static Future<void> init() async {
    try {
      Logger("RepositoriesHelper").info("start");
      await dbRepositorySupervisor.openDatabase(databaseName);
      Logger("RepositoriesHelper").info("finish");
    }
    catch(ex) {
      Logger("RepositoriesHelper").error("Initialization failed: $ex");
    }
  }
}
