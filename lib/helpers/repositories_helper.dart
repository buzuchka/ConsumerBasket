import 'package:consumer_basket/base/logger.dart';
import 'package:consumer_basket/base/repositories/db_repository_supervisor.dart';
import 'package:consumer_basket/repositories/goods.dart';
import 'package:consumer_basket/repositories/purchases.dart';
import 'package:consumer_basket/repositories/purchase_templates.dart';
import 'package:consumer_basket/repositories/purchase_items.dart';
import 'package:consumer_basket/repositories/purchase_template_items.dart';
import 'package:consumer_basket/repositories/shops.dart';

abstract class RepositoriesHelper {

  static const String databaseName = 'CustomerBasket';

  static GoodsRepository goodsRepository = GoodsRepository();
  static ShopsRepository shopsRepository = ShopsRepository();
  static PurchasesRepository purchasesRepository = PurchasesRepository(shopsRepository);
  static PurchaseItemsRepository purchaseItemsRepository = PurchaseItemsRepository(purchasesRepository, goodsRepository);
  static PurchaseTemplatesRepository purchaseTemplatesRepository = PurchaseTemplatesRepository();
  static PurchaseTemplateItemsRepository purchaseTemplateItemsRepository = PurchaseTemplateItemsRepository(purchaseTemplatesRepository, goodsRepository);

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
      await dbRepositorySupervisor.openDatabase(databaseName);
    }
    catch(ex) {
      Logger("RepositoriesHelper").error("Initialization failed: $ex");
    }
  }
}
