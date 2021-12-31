import 'package:consumer_basket/base/logger.dart';
import 'package:consumer_basket/repositories/goods.dart';
import 'package:consumer_basket/repositories/purchases.dart';
import 'package:consumer_basket/repositories/purchase_items.dart';
import 'package:consumer_basket/repositories/shops.dart';
import 'package:consumer_basket/base/repositories/db_repository_supervisor.dart';


abstract class RepositoriesCollection {

  static const String databaseName = 'CustomerBasket';

  static GoodsRepository goodsRepository = GoodsRepository();
  static ShopsRepository shopsRepository = ShopsRepository();
  static PurchasesRepository purchasesRepository = PurchasesRepository(shopsRepository);
  static PurchaseItemsRepository purchaseItemsRepository = PurchaseItemsRepository(purchasesRepository, goodsRepository);

  static DbRepositorySupervisor dbRepositorySupervisor = DbRepositorySupervisor([
    goodsRepository,
    shopsRepository,
    purchasesRepository,
    purchaseItemsRepository,
  ]);

  static Future<void> init() async {
    try {
      await dbRepositorySupervisor.openDatabase(databaseName);
    }
    catch(ex) {
      Logger("RepositoryCollection").error("Initialization failed: $ex");
    }
  }
}
