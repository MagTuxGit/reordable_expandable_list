import 'package:flutter/material.dart';

import 'drag_and_drop_list/drag_and_drop_item.dart';
import 'drag_and_drop_list/drag_and_drop_list_expansion.dart';
import 'drag_and_drop_list/drag_and_drop_list_interface.dart';
import 'drag_and_drop_list/drag_and_drop_lists.dart';

//import 'model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class InnerList {
  final String name;
  List<String> children;

  InnerList({required this.name, required this.children});
}

class _MyHomePageState extends State<MyHomePage> {
  late List<InnerList> _lists;

  @override
  void initState() {
    super.initState();

    _lists = List.generate(4, (outerIndex) {
      return InnerList(
        name: outerIndex.toString(),
        children: List.generate(2, (innerIndex) => '$outerIndex.$innerIndex'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reordable Expandable'),
      ),
      body: DragAndDropLists(
        children: List.generate(_lists.length, (index) => _buildList(index)),
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        // listGhost is mandatory when using expansion tiles to prevent multiple widgets using the same globalkey
        listGhost: const Divider(
            thickness: 5, color: Colors.blue, indent: 16, endIndent: 16),
        itemGhost: const Divider(
            thickness: 5, color: Colors.blue, indent: 16, endIndent: 16),
          listTarget: Container(height: 44, ),
      ),
    );
  }

  DragAndDropListInterface _buildList(int outerIndex) {
    var innerList = _lists[outerIndex];
    return DragAndDropListExpansion(
      title: Text('List ${innerList.name}'),
      disableTopAndBottomBorders: true,
      leading: const Icon(Icons.expand_more),
      trailing: const SizedBox.shrink(),
      children: List.generate(innerList.children.length,
          (index) => _buildItem(innerList.children[index])),
      listKey: ObjectKey(innerList),
      //contentPadding: EdgeInsets.only(left: (item.level + 1) * 24, right: 16),
      contentPadding: const EdgeInsets.only(left: 24, right: 16),
    );
  }

  DragAndDropItem _buildItem(String item) =>
      DragAndDropItem(child: ListTile(title: Text(item)));

  void _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _lists[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  void _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _lists.removeAt(oldListIndex);
      _lists.insert(newListIndex, movedList);
    });
  }
}
