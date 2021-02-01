import 'dart:async';
import 'package:flutter/material.dart';
import '../models/item_model.dart';
import 'loading_container.dart';

class Comment extends StatelessWidget {
  final int itemId;
  final Map<int, Future<ItemModel>> itemMap;
  final int depth;
  Comment({this.itemId, this.itemMap, this.depth});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: itemMap[itemId],
      builder: (context, AsyncSnapshot<ItemModel> snapshot) {
        if (!snapshot.hasData) {
          return LoadingContainer();
        }

        final item = snapshot.data;

        final kidsList = item.kids.map((kidId) {
          return Comment(
            itemId: kidId,
            itemMap: itemMap,
            depth: depth + 1,
          );
        }).toList();

        return Column(
          children: [
            ListTile(
              contentPadding:
                  EdgeInsets.only(right: 16.0, left: (depth + 1) * 16.0),
              title: buildText(item),
              subtitle: Text(item.by == '' ? 'Deleted' : item.by),
            ),
            Divider(),
            ...kidsList,
          ],
        );
      },
    );
  }

  Widget buildText(ItemModel item) {
    final text = item.text
        .replaceAll('&#x27;', "'")
        .replaceAll('<p>', '\n\n')
        .replaceAll('</p>', '')
        .replaceAll('&gt;', '>')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"');

    return Text(text);
  }
}
