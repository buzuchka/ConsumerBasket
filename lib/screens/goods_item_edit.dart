import 'package:flutter/material.dart';

import 'package:consumer_basket/helpers/path_helper.dart';
import 'package:consumer_basket/helpers/repositories_helper.dart';
import 'package:consumer_basket/models/goods.dart';
import 'package:consumer_basket/widgets/item_picture.dart';

// Окно для просмотра и редактирования Товара
class GoodsItemEditScreen extends StatefulWidget {
  final GoodsItem goodsItem; // item to view and update

  const GoodsItemEditScreen({
    Key? key,
    required this.goodsItem
  }) : super(key: key);

  @override
  _GoodsItemEditScreenState createState() => _GoodsItemEditScreenState();
}

class _GoodsItemEditScreenState extends State<GoodsItemEditScreen> {
  bool _isItemDataChanged = false;

  final TextEditingController _titleTextController = TextEditingController();
  final TextEditingController _noteTextController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _titleTextController.text = (widget.goodsItem.title != null)
        ? widget.goodsItem.title!
        : '';
    _noteTextController.text = (widget.goodsItem.note != null)
        ? widget.goodsItem.note!
        : '';
  }

  @override
  void dispose() {
    super.dispose();

    _titleTextController.dispose();
    _noteTextController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("View Goods Item"),
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Text('Delete'),
                    onTap: () async {
                      await _deleteGoodsItem2Database();
                      _clear();
                      Navigator.pop(context, _isItemDataChanged);
                    },
                    value: 1,
                  ),
                ])
          ],
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
                          _getImageWidget()
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
                                child: _getTitleWidget()
                              ),
                            ],
                          ),
                        ],
                      )
                  )
                ],
              ),
              Expanded(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                              child: _getNoteWidget()
                          ),
                        ],
                      ),
                    ],
                  )
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

  Widget _getImageWidget() {
    return ItemPicture(
      imageFilePath: widget.goodsItem.imagePath,
      destinationDir: PathHelper.goodsImagesDir,
      onImageChanged: (String newImagePath) {
        widget.goodsItem.imagePath = newImagePath;
        _updateGoodsItem2Database();
      },
    );
  }

  Widget _getTitleWidget() {
    return TextField(
        controller: _titleTextController,
        maxLines: 2,
        decoration: const InputDecoration(labelText: 'Item Name'),
        onChanged: (String value) {
          widget.goodsItem.title = value;
          _updateGoodsItem2Database();
        }
    );
  }

  Widget _getNoteWidget() {
    return TextField(
        controller: _noteTextController,
        minLines: 4,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        decoration: const InputDecoration(labelText: 'Note'),
        onChanged: (String value) {
          widget.goodsItem.note = value;
          _updateGoodsItem2Database();
        }
    );
  }

  _updateGoodsItem2Database() async {
    await widget.goodsItem.saveToRepository();
    _isItemDataChanged = true;
  }

  _deleteGoodsItem2Database() async {
    await RepositoriesHelper.goodsRepository.delete(widget.goodsItem);
    _isItemDataChanged = true;
  }

  void _clear() {
    _titleTextController.clear();
    _noteTextController.clear();
  }

}
