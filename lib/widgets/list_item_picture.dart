import 'dart:io';

import 'package:flutter/material.dart';

import 'package:consumer_basket/helpers/path_helper.dart';

// Виджет с картинкой для элемента в списке
class ListItemPicture extends StatefulWidget {
  final String? imageFilePath; // путь до картинки
  final double width;  // ширина картинки
  final double height; // высота картинки

  const ListItemPicture({
    Key? key,
    this.imageFilePath,
    this.width = 100.0,
    this.height = 100.0
  }) : super(key: key);

  @override
  _ListItemPictureState createState() => _ListItemPictureState();
}

class _ListItemPictureState extends State<ListItemPicture> {

  Widget _getImageWidget() {
    if (widget.imageFilePath != null) {
      return Image(
          image: FileImage(File(widget.imageFilePath!)),
          width: 100,
          height: 100,
          fit: BoxFit.cover
      );
    }
    else {
      return const AspectRatio(
          aspectRatio: 1.0,
          child: Image(
              image: AssetImage(PathHelper.noPhotoImageFilePath),
              fit: BoxFit.cover)
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _getImageWidget();
  }
}



