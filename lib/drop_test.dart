import 'package:flutter/material.dart';

import 'model.dart';
import 'toggle_list/toggle_list.dart';

class TestDND extends StatefulWidget {
  const TestDND({super.key});

  @override
  State<TestDND> createState() => _TestDNDState();
}

class _TestDNDState extends State<TestDND> {
  List<BlockNode> blockNodes = [];

  @override
  void initState() {
    super.initState();
    blockNodes = Data.blockNodes;
  }

  List<ToggleItem<BlockNode>> get items {
    final List<ToggleItem<BlockNode>> items = [];

    ToggleItem<BlockNode>? currentItem;
    for (int i = 0; i < blockNodes.length; i++) {
      final blockNode = blockNodes[i];
      while (currentItem != null && blockNode.listLevel <= currentItem.level) {
        currentItem = currentItem.parent;
      }

      final item = ToggleItem<BlockNode>(
        node: blockNode,
        nodeIndex: i,
        level: blockNode.listLevel - (currentItem?.level ?? 0),
        isToggle: blockNode.isToggleList,
        parent: currentItem,
        children: [],
      );

      if (currentItem == null) {
        items.add(item);
      } else {
        currentItem.add(item);
      }
      if (blockNode.isToggleList) {
        currentItem = item;
      }
    }

    return items;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ToggleList<BlockNode>(
          items: items,
          nodeBuilder: (node) => _BlockWidget(node),
          onReplaceToEnd: (ToggleItem<BlockNode> data) {
            _replaceBlock(data, blockNodes.length);
          },
          onReplace: _replaceBlock,
        ));
  }

  void _replaceBlock(ToggleItem<BlockNode> data, int blockIndex) {
    final indexFrom = data.nodeIndex;

    int blockIndexTo = indexFrom < blockIndex
        ? blockIndex - (data.children.length + 1)
        : blockIndex;

    if (indexFrom == blockIndexTo) {
      return;
    }

    int levelsToAdd = 0;
    if (blockIndexTo == 0) {
      levelsToAdd = -data.node.listLevel;
    } else {
      final prevBlock = blockNodes[blockIndex - 1];
      levelsToAdd = prevBlock.listLevel +
          (prevBlock.isToggleList ? 1 : 0) -
          data.node.listLevel;
    }

    setState(() {
      blockNodes.removeAt(indexFrom);
      for (final _ in data.children) {
        blockNodes.removeAt(indexFrom);
      }

      // _listViewKey.currentState?.removeItem(indexFrom, (_, __) => Container(),
      //     duration: Duration.zero);

      blockNodes.insert(blockIndexTo, data.node.changeIndex(levelsToAdd));
      for (final child in data.children) {
        blockIndexTo++;
        blockNodes.insert(blockIndexTo, child.node.changeIndex(levelsToAdd));
      }

      //_listViewKey.currentState?.insertItem(itemIndexTo);
    });
  }
}

class _BlockWidget extends StatelessWidget {
  final BlockNode blockNode;

  const _BlockWidget(this.blockNode);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      width: 300,
      alignment: Alignment.centerLeft,
      padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
      child: Text(blockNode.value),
    );
  }
}
