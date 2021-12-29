import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as Path;

import 'package:path_provider/path_provider.dart';

import 'package:image_picker/image_picker.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/models/shop.dart';

// Окно для добавления, просмотра и редактирования Магазина
class ShopEditScreen extends StatefulWidget {
  final Shop shop; // item to view and update

  const ShopEditScreen({
    Key? key,
    required this.shop
  })
      : super(key: key);

  @override
  _ShopEditScreenState createState() => _ShopEditScreenState();
}

class _ShopEditScreenState extends State<ShopEditScreen> {
  bool _isItemDataChanged = false;

  final TextEditingController _titleTextController = TextEditingController();

  XFile? _imageFile;

  @override
  void initState() {
    super.initState();

    _titleTextController.text = (widget.shop.title != null)
        ? widget.shop.title!
        : '';
  }

  @override
  void dispose() {
    super.dispose();
    _titleTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("View Shop"),
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Delete'),
                    onTap: () async {
                      await _deleteShop2Database();
                      _clear();
                      Navigator.pop(context, _isItemDataChanged);
                    },
                    value: 1,
                  ),
                ])
          ],
        ),
        body: Container(
          padding: const EdgeInsets.all(10),
          child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    /*SizedBox(
                        width: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              child: getImageWidget(),
                              onTap: () async {
                                _imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

                                // Если пользователь не выбрал ничего и нажал Назад
                                if(_imageFile == null) {
                                  return;
                                }

                                final currentImagePath = await _copySelectedImage2ExternalDir();
                                widget.goodsItem.imagePath = currentImagePath;
                                _updateGoodsItem2Database();

                                setState(() {});
                              },
                            )
                          ],
                        )
                    ),*/
                    const SizedBox(width: 10),
                    Expanded(
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                    child:
                                    TextField(
                                        controller: _titleTextController,
                                        maxLines: 2,
                                        decoration: const InputDecoration(labelText: 'Item Name'),
                                        onChanged: (String value) {
                                          widget.shop.title = _titleTextController.text;
                                          _updateShop2Database();
                                        }
                                    )
                                ),
                              ],
                            ),
                          ],
                        )
                    )
                  ],
                ),
              ]
          ),
        ),
      ),
      onWillPop: () async {
        Navigator.pop(context, _isItemDataChanged);
        return _isItemDataChanged;
      },
    );
  }

  /*
  Image getImageWidget() {
    if(widget.goodsItem.imagePath != null) {
      return Image.file(
          File(widget.goodsItem.imagePath!),
          width: 100,
          height: 100,
          fit: BoxFit.cover
      );
    } else {
      return const Image(
          image: AssetImage('assets/images/no_photo.jpg'),
          width: 100,
          height: 100,
          fit: BoxFit.cover
      );
    }
  }*/

  _updateShop2Database() async {
    await widget.shop.saveToRepository();
    _isItemDataChanged = true;
  }

  _deleteShop2Database() async {
    await DatabaseHelper.shopsRepository.delete(widget.shop);
    _isItemDataChanged = true;
  }

  Future<String> _copySelectedImage2ExternalDir() async {
    // Путь до папки с файлами приложения
    final extDir = await getExternalStorageDirectory();
    final goodsImagesDir = '${extDir!.path}/images/goods/';

    // Создание папки, в которую будет скопирован файл
    await Directory(goodsImagesDir).create(recursive: true);

    // Копирование файла
    final newImageFilePath = Path.join(goodsImagesDir, _imageFile!.name);
    await _imageFile!.saveTo(newImageFilePath);

    return newImageFilePath;
  }

  void _clear() {
    _titleTextController.clear();
  }

}
