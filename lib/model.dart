import 'id_utils.dart';

class Data {
  static List<BlockNode> blockNodes = [
    BlockNode('Text 0 - alpha', 0),
    BlockNode('Text 0 - beta', 0),
    BlockNode('Toggle 0 - alpha', 0, isToggleList: true),
    BlockNode('Subtext 1 - alpha', 1),
    BlockNode('Subtext 1 - beta', 1),
    BlockNode('Subtoggle 1 - alpha', 1, isToggleList: true),
    BlockNode('Subtext 2 - alpha', 2),
    BlockNode('Subtext 2 - beta', 2),
    BlockNode('Subtoggle 1 - beta', 1, isToggleList: true),
    BlockNode('Subtext 2 - alpha', 2),
    BlockNode('Subtext 2 - beta', 2),
  ];

  static List<EditorItem> items(List<BlockNode> blockNodes) {
    final List<EditorItem> items = [];

    EditorItem? currentItem;
    for (var blockNode in blockNodes) {
      while (currentItem != null && blockNode.listLevel <= currentItem.level) {
        currentItem = currentItem.parent;
      }
      final item = EditorItem(blockNode, currentItem, []);

      items.add(item);

      if (currentItem == null) {
        //items.add(item);
      } else {
        currentItem.add(item);
      }
      if (blockNode.isToggleList) {
        currentItem = item;
      }
    }

    return items;
  }
}

class EditorItem {
  final BlockNode blockNode;
  final EditorItem? parent;
  final List<EditorItem> children;

  EditorItem(this.blockNode, this.parent, this.children);

  int get level => blockNode.listLevel;

  bool get isToggle => blockNode.isToggleList;

  void add(EditorItem child) {
    children.add(child);
  }
}

class BlockNode {
  final String id;
  final String value;
  final bool isToggleList;
  final int listLevel;

  BlockNode(this.value, this.listLevel, {this.isToggleList = false})
      : id = ItemIdUtils.newEntityId();
}
