import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import 'package:consumer_basket/models/abstract_model.dart';

const String databaseName = 'CustomerBasket';

abstract class DatabaseHelper {
  static late Database _db;

  static int get _version => 1;

  static Future<void> init() async {
    try {
      String _databaseFilePath = join(await getDatabasesPath(), databaseName);
      _db = await openDatabase(_databaseFilePath, version: _version, onCreate: _onCreate);
    }
    catch(ex) {
      print(ex);
    }
  }

  static void _onCreate(Database db, int version) async {
    await db.execute(
        'CREATE TABLE goods ('
            'id INTEGER PRIMARY KEY NOT NULL, '
            'title STRING,'
            'image_path STRING)');
    await db.execute(
        'CREATE TABLE shops ('
            'id INTEGER PRIMARY KEY NOT NULL, '
            'title STRING)');
  }

  static Future<List<Map<String, dynamic>>> query(String table) async =>
      _db.query(table);

  static Future<int> insert(String table, Model model) async =>
      await _db.insert(table, model.toMap());

  static Future<int> update(String table, Model model) async =>
      await _db.update(table, model.toMap(), where: 'id = ?', whereArgs: [model.id]);

  static Future<int> delete(String table, Model model) async =>
      await _db.delete(table, where: 'id = ?', whereArgs: [model.id]);
}
