import 'package:consumer_basket/repositories/shops.dart';
import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

import 'package:consumer_basket/repositories/goods.dart';
import 'package:consumer_basket/repositories/purchases.dart';
import 'package:consumer_basket/repositories/shops.dart';

const String databaseName = 'CustomerBasket';

abstract class DatabaseHelper {
  static late Database db;
  static late GoodsRepository goodsRepository;
  static late ShopsRepository shopsRepository;
  static late PurchasesRepository purchasesRepository;

  static int get _version => 1;

  static Future<void> init() async {
    try {
      String _databaseFilePath = join(await getDatabasesPath(), databaseName);
      db = await openDatabase(
          _databaseFilePath,
          version: _version,
          onCreate: _onCreate
      );
      goodsRepository = GoodsRepository(db);
      shopsRepository = ShopsRepository(db);
      purchasesRepository = PurchasesRepository(db, shopsRepository);

      await goodsRepository.createIfNotExists();
      await shopsRepository.createIfNotExists();
      await purchasesRepository.createIfNotExists();
    }
    catch(ex) {
      print("Cought error: $ex");
    }
  }

  static void _onCreate(Database db, int version) async {
    // await db.execute(
    //     'CREATE TABLE purchase_item ('
    //         'purchase_id INTEGER NOT NULL, '
    //         'goods_id INTEGER NOT NULL, '
    //         'goods_price REAL NOT NULL, '
    //         'goods_count INTEGER NOT NULL, '
    //         'PRIMARY KEY(purchase_id, goods_id), '
    //         'FOREIGN KEY (purchase_id) REFERENCES purchases (id) '
    //         'ON DELETE CASCADE ON UPDATE NO ACTION, '
    //         'FOREIGN KEY (goods_id) REFERENCES goods (id) '
    //         'ON DELETE CASCADE ON UPDATE NO ACTION'
    //         ')');
  }
}
