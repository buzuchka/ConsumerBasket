import 'package:flutter/material.dart';

import 'package:consumer_basket/helpers/path_helper.dart';
import 'package:consumer_basket/helpers/repositories_helper.dart';
import 'package:consumer_basket/models/shop.dart';
import 'package:consumer_basket/widgets/item_picture.dart';

// Окно для добавления, просмотра и редактирования Магазина
class ShopEditScreen extends StatefulWidget {
  final Shop shop; // item to view and update

  const ShopEditScreen({
    Key? key,
    required this.shop
  }) : super(key: key);

  @override
  _ShopEditScreenState createState() => _ShopEditScreenState();
}

class _ShopEditScreenState extends State<ShopEditScreen> {
  bool _isItemDataChanged = false;

  final TextEditingController _titleTextController = TextEditingController();

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
                    SizedBox(
                        width: 100,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            ItemPicture(
                              imageFilePath: widget.shop.imagePath,
                              destinationDir: PathHelper.shopsImagesDir,
                              onImageChanged: (String newImagePath) {
                                widget.shop.imagePath = newImagePath;
                                _updateShop2Database();
                              },
                            ),
                          ],
                        )
                    ),
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

  _updateShop2Database() async {
    await widget.shop.saveToRepository();
    _isItemDataChanged = true;
  }

  _deleteShop2Database() async {
    await RepositoriesHelper.shopsRepository.delete(widget.shop);
    _isItemDataChanged = true;
  }

  void _clear() {
    _titleTextController.clear();
  }

}
