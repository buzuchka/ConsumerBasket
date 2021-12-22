import 'dart:io';

import 'package:flutter/material.dart';

import 'package:path/path.dart' as Path;

import 'package:path_provider/path_provider.dart';

import 'package:image_picker/image_picker.dart';

import 'package:consumer_basket/common/database_helper.dart';
import 'package:consumer_basket/models/goods.dart';

// Диалоговое окно для добавления и редактирования Товара
class GoodsItemEditDialog extends StatefulWidget {
  GoodsItem? goodsItem; // item to view and update
  VoidCallback onDataChanged;

  GoodsItemEditDialog({Key? key, required this.onDataChanged, this.goodsItem})
      : super(key: key);

  @override
  _GoodsItemEditDialogState createState() => _GoodsItemEditDialogState();
}

class _GoodsItemEditDialogState extends State<GoodsItemEditDialog> {
  GoodsItem _newGoodsItem = GoodsItem();

  XFile? _imageFile;

  final TextEditingController _titleTextController = TextEditingController();

  bool _isItemDataChanged = false;

  @override
  void initState() {
    super.initState();

    bool isUpdateMode = widget.goodsItem != null;
    _titleTextController.text = isUpdateMode ? widget.goodsItem!.title! : '';
  }

  @override
  void dispose() {
    super.dispose();
    _titleTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isUpdateMode = widget.goodsItem != null;
    return Dialog(
      child: Container(
        padding: const EdgeInsets.all(15),
        child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add GoodsItem',
                style: TextStyle(fontSize: 20),
                textAlign: TextAlign.left,
              ),
              const SizedBox(height: 10),
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
                          getImageWidget(isUpdateMode),
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

                                // Если текущий режим - обновление существующего элемента
                                if (isUpdateMode) {
                                  final currentImagePath = await _copySelectedImage2ExternalDir();
                                  widget.goodsItem!.imagePath = currentImagePath;
                                  _updateGoodsItem2Database(widget.goodsItem!);
                                }
                                else {
                                  _newGoodsItem.imagePath = _imageFile!.path;
                                }

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
                              if (isUpdateMode) {
                                widget.goodsItem!.title = _titleTextController.text;
                                _updateGoodsItem2Database(widget.goodsItem!);
                              }
                            },
                          ),
                        ],
                      )
                  )
                ],
              ),
              //const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Visibility(
                            visible: isUpdateMode,
                            child: ElevatedButton(
                                child: const Text('Delete'),
                                onPressed: () async {
                                  await _deleteGoodsItem2Database(widget.goodsItem!);
                                  _close();
                                })),
                        const SizedBox(width: 10),
                      ]),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Visibility(
                          visible: isUpdateMode,
                          child: ElevatedButton(
                              child: const Text('Close'),
                              onPressed: () {
                                _close();
                              })),
                      Visibility(
                          visible: !isUpdateMode,
                          child: ElevatedButton(
                              child: const Text('Cancel'),
                              onPressed: () {
                                _close();
                              })),
                      Visibility(
                          visible: !isUpdateMode,
                          child: const SizedBox(width: 10)),
                      Visibility(
                          visible: !isUpdateMode,
                          child: ElevatedButton(
                              child: const Text('Add'),
                              onPressed: () async {
                                _newGoodsItem.title = _titleTextController.text;

                                if(_imageFile != null) {
                                  final currentImagePath = await _copySelectedImage2ExternalDir();
                                  _newGoodsItem.imagePath = currentImagePath;
                                }

                                await _addGoodsItem2Database(_newGoodsItem);
                                _close();
                              })),
                    ],
                  ),
                ],
              )
            ]
        ),
      ),
    );
  }

  Image getImageWidget(bool isUpdateMode) {
    if(isUpdateMode &&
        widget.goodsItem!.imagePath != null) {
      return Image.file(
          File(widget.goodsItem!.imagePath!),
          width: 100,
          height: 100,
          fit: BoxFit.cover
      );
    }
    else if(!isUpdateMode && _newGoodsItem.imagePath != null) {
      return Image.file(
          File(_newGoodsItem.imagePath!),
          width: 100,
          height: 100,
          fit: BoxFit.cover
      );
    }
    else {
      return const Image(
          image: AssetImage('assets/images/no_photo.jpg'),
          width: 100,
          height: 100,
          fit: BoxFit.cover
      );
    }
  }

  _addGoodsItem2Database(GoodsItem item) async {
    await DatabaseHelper.insert(GoodsItem.tableName, item);
    _isItemDataChanged = true;
  }

  _updateGoodsItem2Database(GoodsItem item) async {
    await DatabaseHelper.update(GoodsItem.tableName, item);
    _isItemDataChanged = true;
  }

  _deleteGoodsItem2Database(GoodsItem item) async {
    await DatabaseHelper.delete(GoodsItem.tableName, item);
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
    if(_isItemDataChanged) {
      widget.onDataChanged.call();
    }
    Navigator.of(context).pop();
  }
}
