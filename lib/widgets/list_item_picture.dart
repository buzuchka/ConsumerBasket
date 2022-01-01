import 'package:flutter/material.dart';

import 'package:consumer_basket/widgets/image.dart';

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

  @override
  Widget build(BuildContext context) {
    return getImageWidget(widget.imageFilePath, widget.width, widget.height);
  }
}
