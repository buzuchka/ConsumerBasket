import 'dart:io';

import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';

import 'package:path/path.dart' as path_lib;

import 'package:consumer_basket/widgets/base/image.dart';

// Виджет с картинкой
// При нажатии открывается окно выбора картинки из Галереи
class ItemPicture extends StatefulWidget {
  final String? imageFilePath; // путь до картинки
  final String destinationDir; // путь до папки, в которую необходимо поместить выбранную картинку
  final void Function(String) onImageChanged;
  final double width;  // ширина картинки
  final double height; // высота картинки

  const ItemPicture({
    Key? key,
    required this.destinationDir,
    required this.onImageChanged,
    this.imageFilePath,
    this.width = 100.0,
    this.height = 100.0
  }) : super(key: key);

  @override
  _ItemPictureState createState() => _ItemPictureState();
}

class _ItemPictureState extends State<ItemPicture> {
  XFile? _imageFile;
  String? _selectedImageFilePath;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: _getImageWidget(),
      onTap: () async {
        _imageFile = await ImagePicker().pickImage(source: ImageSource.gallery);

        // Если пользователь не выбрал ничего и нажал Назад
        if(_imageFile == null) {
          return;
        }

        // Если картинка уже была, то ее надо сначала удалить
        if(widget.imageFilePath != null) {
          await _deletePreviousImage();
        }

        // Копировать выбранную картинку в нужную папку
        _selectedImageFilePath = await _copySelectedImage(widget.destinationDir);

        // Обновить картинку
        setState(() {});

        // Отправить сигнал о том, что картинка изменилась, пусть родитель забирает путь до нее и обновляет у себя
        widget.onImageChanged(_selectedImageFilePath!);
      },
    );
  }

  Widget _getImageWidget() {
    if(_selectedImageFilePath != null) {
      return Image.file(
          File(_selectedImageFilePath!),
          width: widget.width,
          height: widget.height,
          fit: BoxFit.cover
      );
    } else {
      return getImageWidget(widget.imageFilePath, widget.width, widget.height);
    }
  }

  _deletePreviousImage() async {
    return await File(widget.imageFilePath!).delete();
  }

  Future<String> _copySelectedImage(String destinationDir) async {
    final newImageFilePath = path_lib.join(destinationDir, _imageFile!.name);
    await _imageFile!.saveTo(newImageFilePath);
    return newImageFilePath;
  }
}
