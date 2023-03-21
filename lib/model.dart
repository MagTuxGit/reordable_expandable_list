import 'dart:math';

import 'id_utils.dart';

class Data {
  // static List<BlockNode> blockNodes = [
  //   BlockNode(value: 'Text 0 - alpha', listLevel: 0),
  //   BlockNode(value: 'Text 0 - beta', listLevel: 0),
  //   BlockNode(value: 'Toggle 0 - alpha', listLevel: 0, isToggleList: true),
  //   BlockNode(value: 'Subtext 1 - alpha', listLevel: 1),
  //   BlockNode(value: 'Subtext 1 - beta', listLevel: 1),
  //   BlockNode(value: 'Text 0 - gamma', listLevel: 0),
  //   BlockNode(value: 'Text 0 - delta', listLevel: 0),
  // ];

  // static List<BlockNode> blockNodes = [
  //   BlockNode(value: 'Text 0 - alpha', listLevel: 0),
  //   BlockNode(value: 'Text 0 - beta', listLevel: 0),
  //   BlockNode(value: 'Toggle 0 - alpha', listLevel: 0, isToggleList: true),
  //   BlockNode(value: 'Subtext 1 - alpha', listLevel: 1),
  //   BlockNode(value: 'Subtext 1 - beta', listLevel: 1),
  //   BlockNode(value: 'Subtoggle 1 - alpha', listLevel: 1, isToggleList: true),
  //   BlockNode(value: 'Subtext 2 - alpha', listLevel: 2),
  //   BlockNode(value: 'Subtext 2 - beta', listLevel: 2),
  //   BlockNode(value: 'Subtoggle 1 - beta', listLevel: 1, isToggleList: true),
  //   BlockNode(value: 'Subtext 2 - alpha', listLevel: 2),
  //   BlockNode(value: 'Subtext 2 - beta', listLevel: 2),
  // ];

  static List<BlockNode> blockNodes = [
    BlockNode(value: 'Text 0 - alpha', listLevel: 0),
    BlockNode(value: 'Text 0 - beta', listLevel: 0),
    BlockNode(value: 'Toggle 0 - alpha', listLevel: 0, isToggleList: true),
    BlockNode(value: 'Subtext 1', listLevel: 1),
    BlockNode(value: 'Subtext 2', listLevel: 2),
    BlockNode(value: 'Subtext 3', listLevel: 3),
    BlockNode(value: 'Subtext 4', listLevel: 4),
    BlockNode(value: 'Subtoggle 1 - beta', listLevel: 1, isToggleList: true),
    BlockNode(value: 'Subtext 2 - alpha', listLevel: 2),
    BlockNode(value: 'Subtext 2 - beta', listLevel: 2),
  ];
}

class EditorItem {
  final int blockNodeIndex;
  final BlockNode blockNode;
  final EditorItem? parent;
  final List<EditorItem> children;
  late final int level;

  EditorItem(this.blockNodeIndex, this.blockNode, this.parent, this.children) {
    if (parent == null) {
      level = blockNode.listLevel;
    } else {
      level = blockNode.listLevel - parent!.level;
    }
  }

  bool get isToggle => blockNode.isToggleList;

  bool get expanded => true;

  String get title => blockNode.value;

  void add(EditorItem child) {
    children.add(child);
  }
}

class BlockNode {
  final String id;
  final String value;
  final bool isToggleList;
  final int listLevel;

  BlockNode({String? id, required this.value, required this.listLevel, this.isToggleList = false})
      : id = id ?? ItemIdUtils.newEntityId();

  BlockNode changeIndex(int levelsToAdd) =>
      BlockNode(
        id: id,
        value: value,
        listLevel: max(0, min(7, listLevel + levelsToAdd)),
        isToggleList: isToggleList,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlockNode && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
