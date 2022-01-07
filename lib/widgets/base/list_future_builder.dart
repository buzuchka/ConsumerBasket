import 'package:flutter/material.dart';

import 'package:consumer_basket/core/helpers/constants.dart';
import 'package:consumer_basket/core/internationalization/languages/language.dart';

typedef ItemWidgetCreator<ItemWidgetT extends Widget, ItemT> = ItemWidgetT? Function(ItemT);

typedef Action<ItemT> = Future<void> Function(BuildContext, ItemT);

typedef OnRebuildAction = Function();

FutureBuilder<List<ItemT>> getListFutureBuilder<ItemWidgetT extends Widget, ItemT>(
    Future<List<ItemT>> future,
    ItemWidgetCreator<ItemWidgetT, ItemT> itemWidgetCreator,
    {Action<ItemT>? onTap,
    Action<ItemT>? onLongPress}
    ) {
  return FutureBuilder<List<ItemT>>(
      future: future,
      initialData: const [],
      builder: (context, snapshot) {
        if(snapshot.connectionState == ConnectionState.waiting) {
          return _getProgressWidget(context);
        } else if(snapshot.hasError) {
          return _getErrorWidget(context, snapshot.error.toString());
        } else {
          return _getListWidget(context, snapshot.data!, itemWidgetCreator, onTap, onLongPress);
        }
      }
  );
}

Action<ItemT> editItemOnTap<ItemEditorT extends Widget, ItemT>(
    ItemWidgetCreator<ItemEditorT, ItemT> itemEditorCreator,
    OnRebuildAction onRebuildAction,
){
  return (BuildContext context, ItemT item) async {
    var editor = itemEditorCreator(item);
    if(editor == null){
      return;
    }
    final isNeed2Rebuild = await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => editor,
      ),
    );
    if(isNeed2Rebuild) {
      onRebuildAction();
    }
  };
}

Widget _getListWidget<ItemWidgetT extends Widget, ItemT>(
    BuildContext context,
    List<ItemT> items,
    ItemWidgetCreator<ItemWidgetT, ItemT> itemWidgetCreator,
    Action<ItemT>? onTapAction,
    Action<ItemT>? onLongPressAction,
    ) {
  return ListView.separated(
    padding: const EdgeInsets.all(Constants.spacing),
    itemCount: items.length,
    itemBuilder: (_, int position) {
      final currentItem = items.elementAt(position);
      GestureTapCallback? onTap;
      GestureLongPressCallback? onLongPress;
      if(onTapAction != null){
        onTap = () async {
          await onTapAction(context, currentItem);
        };
      }
      if(onLongPressAction != null){
        onLongPress = () async {
          await onLongPressAction(context, currentItem);
        };
      }
      return InkWell(
          child: itemWidgetCreator(currentItem),
          onTap: onTap,
          onLongPress: onLongPress,
      );
    },
    separatorBuilder: (context, index) {
      return const Divider();
    },
  );
}

Widget _getProgressWidget(BuildContext context) {
  double size = Constants.progressIndicatorSize;
  return Center(
      child: SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            backgroundColor: Theme.of(context).colorScheme.primary,
            color: Constants.progressIndicatorSecondColor,
          )
      )
  );
}

Widget _getErrorWidget(BuildContext context, String errorText) {
  return Container(
      padding: const EdgeInsets.all(Constants.spacing),
      child: Text(
        '${Language.of(context).errorString}: $errorText',
        style: Theme.of(context).textTheme.bodyText2!.copyWith(
            color: Theme.of(context).colorScheme.error
        )
      )
  );
}
