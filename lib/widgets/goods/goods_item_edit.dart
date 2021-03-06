import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/helpers/path_helper.dart';
import 'package:consumer_basket/core/helpers/repositories_helper.dart';
import 'package:consumer_basket/core/internationalization/languages/language.dart';
import 'package:consumer_basket/core/models/goods.dart';

import 'package:consumer_basket/widgets/base/item_picture.dart';

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
          title: Text(Language.of(context).goodsItemString),
          actions: [
            PopupMenuButton(
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text(Language.of(context).deleteButtonName),
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
          padding: const EdgeInsets.all(Constants.spacing),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(
                  width: Constants.listItemPictureHeight,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _getImageWidget()
                    ],
                  )
              ),
              const SizedBox(height: Constants.spacing),
              Container(
                  child: _getTitleWidget()
              ),
              const SizedBox(height: Constants.spacing),
              Expanded(
                  child: _getNoteWidget()
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
        decoration: InputDecoration(
            labelText: Language.of(context).titleString
        ),
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
        decoration: InputDecoration(
            labelText: Language.of(context).goodsItemNoteName
        ),
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
