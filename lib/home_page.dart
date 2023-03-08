import 'package:flutter/material.dart';

import 'model.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<BlockNode> blockNodes = [];

  @override
  void initState() {
    super.initState();
    blockNodes = Data.blockNodes;
  }

  @override
  Widget build(BuildContext context) {
    final items = Data.items(blockNodes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reordable Expandable'),
      ),
      body: _ReordableListBranch(items, onReorder),
    );
  }

  void onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      if (oldIndex == newIndex) return;

      assert(oldIndex > -1 &&
          oldIndex < blockNodes.length &&
          newIndex > -1 &&
          newIndex < blockNodes.length);

      final node = blockNodes.removeAt(oldIndex);
      blockNodes.insert(newIndex, node);
    });
  }
}

class _ReordableListBranch extends StatelessWidget {
  final List<EditorItem> items;
  final ReorderCallback onReorder;

  const _ReordableListBranch(this.items, this.onReorder);

  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      itemCount: items.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        final item = items[index];
        return Container(
          key: ValueKey(item.blockNode.id),
          child: ListTile(
            title: Text(item.blockNode.value),
            leading: item.isToggle
                ? const Icon(Icons.expand_more)
                : null,
            minLeadingWidth: 0,
            horizontalTitleGap: 0,
            contentPadding:
                EdgeInsets.only(left: (item.level + 1) * 24, right: 16),
          ),
        );
      },
      onReorder: onReorder,
    );
  }
}

//_ReordableListBranch([item, ...item.children], onReorder)

//item.children.map((child) =>ListTile(title: Text(child.blockNode.value))).toList()

// item.isToggle
// ? ExpansionTile(
// title: Text(item.blockNode.value),
// tilePadding:
// EdgeInsets.only(left: (item.level + 1) * 16, right: 16),
// children: [_ReordableListBranch(item.children, onReorder)])
// :
