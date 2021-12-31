import 'dart:io';

import 'package:path/path.dart' as path_lib;

import 'package:path_provider/path_provider.dart';

class PathHelper {
  static late String goodsImagesDir;
  static late String shopsImagesDir;

  static late Directory? _appDir;   // Путь до папки с файлами приложения
  static late String _appImagesDir; // Путь до папки с картинками приложения

  static Future<void> init() async {
    _appDir = await getExternalStorageDirectory();
    assert(_appDir != null);

    _appImagesDir = path_lib.join(_appDir!.path, 'images');
    await Directory(_appImagesDir).create();

    goodsImagesDir = path_lib.join(_appImagesDir, 'goods');
    await Directory(goodsImagesDir).create();

    shopsImagesDir = path_lib.join(_appImagesDir, 'shops');
    await Directory(shopsImagesDir).create();
  }
}
