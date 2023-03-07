class Data {
  static List<BlockNode> blockNodes = [
    BlockNode('Text 0 - alpha', 0),
    BlockNode('Text 0 - beta', 0),
    BlockNode('Toggle 0 - alpha', 0, isToggle: true),
    BlockNode('Subtext 1 - alpha', 1),
    BlockNode('Subtext 1 - beta', 1),
    BlockNode('Subtoggle 1 - alpha', 1),
    BlockNode('Subtext 2 - alpha', 2),
    BlockNode('Subtext 2 - beta', 2),
    BlockNode('Subtoggle 1 - beta', 1),
    BlockNode('Subtext 2 - alpha', 2),
    BlockNode('Subtext 2 - beta', 2),
  ];
}

class EditorItem {
  final BlockNode blockNode;
  final EditorItem? parent;
  final List<EditorItem> children;

  EditorItem(this.blockNode, this.parent, this.children);

  int get level => blockNode.level;

  void add(EditorItem child) {
    children.add(child);
  }
}

class BlockNode {
  final String value;
  final bool isToggle;
  final int level;

  BlockNode(this.value, this.level, {this.isToggle = false});
}
