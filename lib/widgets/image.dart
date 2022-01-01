import 'dart:io';

import 'package:flutter/material.dart';

import 'package:consumer_basket/helpers/path_helper.dart';

Widget getImageWidget(String? imageFilePath, double width, double height) {
  if (imageFilePath != null) {
    return Image(
        image: FileImage(File(imageFilePath)),
        width: width,
        height: height,
        fit: BoxFit.cover
    );
  }
  else {
    return Image(
        image: const AssetImage(PathHelper.noPhotoImageFilePath),
        width: width,
        height: height,
        fit: BoxFit.cover
    );
  }
}