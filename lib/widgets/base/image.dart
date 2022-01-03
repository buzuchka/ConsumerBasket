import 'dart:io';

import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/path_helper.dart';

Widget getImageWidget(String? imageFilePath, double width, double height) {
  if (imageFilePath != null) {
    return Image(
        image: FileImage(File(imageFilePath)),
        width: width,
        height: height,
        fit: BoxFit.cover
    );
  }
  return getNoPhotoImageWidget(width, height);
}

Widget getNoPhotoImageWidget(double width, double height) {
  return Image(
      image: const AssetImage(PathHelper.noPhotoImageFilePath),
      width: width,
      height: height,
      fit: BoxFit.cover
  );
}