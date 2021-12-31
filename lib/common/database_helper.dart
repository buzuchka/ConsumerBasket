import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

import 'package:consumer_basket/repositories/goods.dart';
import 'package:consumer_basket/repositories/purchases.dart';
import 'package:consumer_basket/repositories/purchase_items.dart';
import 'package:consumer_basket/repositories/shops.dart';
import 'package:consumer_basket/base/repositories/db_repository_supervisor.dart';

const String databaseName = 'CustomerBasket';

abstract class DatabaseHelper {
  static late Database db;
  static late GoodsRepository goodsRepository;
  static late ShopsRepository shopsRepository;
  static late PurchasesRepository purchasesRepository;
  static late PurchaseItemsRepository purchaseItemsRepository;
  static late DbRepositorySupervisor dbRepositorySupervisor;

  static Future<void> init() async {
    try {
      goodsRepository = GoodsRepository();
      shopsRepository = ShopsRepository();
      purchasesRepository = PurchasesRepository(shopsRepository);
      purchaseItemsRepository = PurchaseItemsRepository(purchasesRepository, goodsRepository);

      dbRepositorySupervisor = DbRepositorySupervisor([
        goodsRepository,
        shopsRepository,
        purchasesRepository,
        purchaseItemsRepository
      ]);

      await dbRepositorySupervisor.openDatabase(databaseName);
      // await goodsRepository.createIfNotExists();
      // await shopsRepository.createIfNotExists();
      // await purchasesRepository.createIfNotExists();
      // await purchaseItemsRepository.createIfNotExists();
    }
    catch(ex) {
      print("Cough error: $ex");
    }
  }
}
