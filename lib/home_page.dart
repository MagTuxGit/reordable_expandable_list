import 'package:flutter/material.dart';

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
  //List<BlockNode> blockNodes = [];
  late List<InnerList> _lists;

  @override
  void initState() {
    super.initState();
    //blockNodes = Data.blockNodes;

    _lists = List.generate(5, (outerIndex) {
      return InnerList(
        name: outerIndex.toString(),
        children: List.generate(5, (innerIndex) => '$outerIndex.$innerIndex'),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reordable Expandable'),
      ),
      //body: _ReordableListBranch(items, onReorder),
      body: DragAndDropLists(
        children: List.generate(_lists.length, (index) => _buildList(index)),
        onItemReorder: _onItemReorder,
        onListReorder: _onListReorder,
        // listGhost is mandatory when using expansion tiles to prevent multiple widgets using the same globalkey
        listGhost: const Divider(
            thickness: 5, color: Colors.blue, indent: 16, endIndent: 16),
        itemGhost: const Divider(
            thickness: 5, color: Colors.blue, indent: 16, endIndent: 16),
        // listGhost: Padding(
        //   padding: const EdgeInsets.symmetric(vertical: 16),
        //   child: Center(
        //     child: Container(
        //       padding:
        //           const EdgeInsets.symmetric(vertical: 16, horizontal: 100.0),
        //       decoration: BoxDecoration(
        //         border: Border.all(),
        //         borderRadius: BorderRadius.circular(7.0),
        //       ),
        //       child: const Icon(Icons.add_box),
        //     ),
        //   ),
        // ),
      ),
    );
  }

  _buildList(int outerIndex) {
    var innerList = _lists[outerIndex];
    return DragAndDropListExpansion(
      title: Text('List ${innerList.name}'),
      //subtitle: Text('Subtitle ${innerList.name}'),
      //leading: const Icon(Icons.ac_unit),
      children: List.generate(innerList.children.length,
          (index) => _buildItem(innerList.children[index])),
      listKey: ObjectKey(innerList),
    );
  }

  _buildItem(String item) {
    return DragAndDropItem(child: ListTile(title: Text(item)));
  }

  _onItemReorder(
      int oldItemIndex, int oldListIndex, int newItemIndex, int newListIndex) {
    setState(() {
      var movedItem = _lists[oldListIndex].children.removeAt(oldItemIndex);
      _lists[newListIndex].children.insert(newItemIndex, movedItem);
    });
  }

  _onListReorder(int oldListIndex, int newListIndex) {
    setState(() {
      var movedList = _lists.removeAt(oldListIndex);
      _lists.insert(newListIndex, movedList);
    });
  }
}
