import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as Path;

import 'package:path_provider/path_provider.dart';

import 'package:image_picker/image_picker.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/models/goods.dart';

// Окно для добавления, просмотра и редактирования Товара
class GoodsItemViewEditScreen extends StatefulWidget {
  final GoodsItem goodsItem; // item to view and update

  const GoodsItemViewEditScreen({
    Key? key,
    required this.goodsItem
  })
      : super(key: key);

  @override
  _GoodsItemViewEditScreenState createState() => _GoodsItemViewEditScreenState();
}

class _GoodsItemViewEditScreenState extends State<GoodsItemViewEditScreen> {
  bool _isItemDataChanged = false;

  final TextEditingController _titleTextController = TextEditingController();

  XFile? _imageFile;

  @override
  void initState() {
    super.initState();

    _titleTextController.text = (widget.goodsItem.title != null)
        ? widget.goodsItem.title!
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
          title: const Text("View Goods Item")
        ),
        body: Container(
          padding: const EdgeInsets.all(15),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                      width: 100,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          getImageWidget(),
                          ElevatedButton(
                              child: const Text(
                                'Change\nimage',
                                maxLines: 2,
                                textAlign: TextAlign.center,),
                              onPressed: () async {
                                _imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

                                // Если пользователь не выбрал ничего и нажал Назад
                                if(_imageFile == null) {
                                  return;
                                }

                                final currentImagePath = await _copySelectedImage2ExternalDir();
                                widget.goodsItem.imagePath = currentImagePath;
                                _updateGoodsItem2Database(widget.goodsItem);

                                setState(() {});
                              }
                          )
                        ],
                      )
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                        children: [
                          TextField(
                            controller: _titleTextController,
                            decoration: const InputDecoration(labelText: 'Item Name'),
                            onChanged: (String value) {
                                widget.goodsItem.title = _titleTextController.text;
                                _updateGoodsItem2Database(widget.goodsItem);
                              }
                          ),
                        ],
                      )
                  )
                ],
              ),
              //const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    child: const Text('Delete'),
                    onPressed: () async {
                      await _deleteGoodsItem2Database(widget.goodsItem);
                      _close();
                    }
                  ),
                ],
              )
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
  }

  _updateGoodsItem2Database(GoodsItem item) async {
    await item.saveToRepository();
    // await DatabaseHelper.goodsRepository.update(item);
    _isItemDataChanged = true;
  }

  _deleteGoodsItem2Database(GoodsItem item) async {
    await DatabaseHelper.goodsRepository.delete(item);
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

  void _close() {
    _clear();
    Navigator.pop(context, _isItemDataChanged);
  }
}
