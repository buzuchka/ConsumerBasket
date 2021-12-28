import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

import 'package:consumer_basket/repositories/goods.dart';
import 'package:consumer_basket/repositories/purchases.dart';
import 'package:consumer_basket/repositories/purchase_items.dart';
import 'package:consumer_basket/repositories/shops.dart';

const String databaseName = 'CustomerBasket';

abstract class DatabaseHelper {
  static late Database db;
  static late GoodsRepository goodsRepository;
  static late ShopsRepository shopsRepository;
  static late PurchasesRepository purchasesRepository;
  static late PurchaseItemsRepository purchaseItemsRepository;

  static int get _version => 1;

  static Future<void> init() async {
    try {
      String _databaseFilePath = join(await getDatabasesPath(), databaseName);
      db = await openDatabase(
          _databaseFilePath,
          version: _version
      );
      goodsRepository = GoodsRepository(db);
      shopsRepository = ShopsRepository(db);
      purchasesRepository = PurchasesRepository(db, shopsRepository);
      purchaseItemsRepository = PurchaseItemsRepository(db, purchasesRepository, goodsRepository);

      await goodsRepository.createIfNotExists();
      await shopsRepository.createIfNotExists();
      await purchasesRepository.createIfNotExists();
      await purchaseItemsRepository.createIfNotExists();
    }
    catch(ex) {
      print("Cought error: $ex");
    }
  }
}
