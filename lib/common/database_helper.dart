import 'package:sqflite/sqflite.dart';

import 'package:path/path.dart';

import 'package:consumer_basket/repositories/goods.dart';
import 'package:consumer_basket/repositories/purchases.dart';

const String databaseName = 'CustomerBasket';

abstract class DatabaseHelper {
  static late Database db;
  static late GoodsRepository goodsRepository;
  static late PurchasesRepository purchasesRepository;

  static int get _version => 1;

  static Future<void> init() async {
    try {
      String _databaseFilePath = join(await getDatabasesPath(), databaseName);
      db = await openDatabase(
          _databaseFilePath,
          version: _version,
          onConfigure: _onConfigure,
          onCreate: _onCreate
      );
      goodsRepository = GoodsRepository(db);
      purchasesRepository = PurchasesRepository(db);
    }
    catch(ex) {
      print(ex);
    }
  }

  static void _onConfigure(Database db) async {
    // Add support for cascade delete
    await db.execute("PRAGMA foreign_keys = ON");
  }

  static void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE goods ('
            'id INTEGER PRIMARY KEY NOT NULL, '
            'title TEXT(50), '
            'image_path TEXT'
            ')');
    await db.execute(
        'CREATE TABLE purchases ('
            'id INTEGER PRIMARY KEY NOT NULL, '
            'shop_id INTEGER, '
            'date_text TEXT(25), '
            'FOREIGN KEY (shop_id) REFERENCES shops (id) '
            'ON DELETE CASCADE ON UPDATE NO ACTION'
            ')');
    await db.execute(
        'CREATE TABLE purchase_item ('
            'purchase_id INTEGER NOT NULL, '
            'goods_id INTEGER NOT NULL, '
            'goods_price REAL NOT NULL, '
            'goods_count INTEGER NOT NULL, '
            'PRIMARY KEY(purchase_id, goods_id), '
            'FOREIGN KEY (purchase_id) REFERENCES purchases (id) '
            'ON DELETE CASCADE ON UPDATE NO ACTION, '
            'FOREIGN KEY (goods_id) REFERENCES goods (id) '
            'ON DELETE CASCADE ON UPDATE NO ACTION'
            ')');
    await db.execute(
        'CREATE TABLE shops ('
            'id INTEGER PRIMARY KEY NOT NULL, '
            'title TEXT(50)'
            ')');
  }
}
