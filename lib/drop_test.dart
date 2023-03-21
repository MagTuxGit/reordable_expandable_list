import 'dart:math';

import 'package:flutter/material.dart';

import 'drag_and_drop_list/programmatic_expansion_tile.dart';
import 'model.dart';

final PageStorageBucket _pageStorageBucket = PageStorageBucket();

class TestDND extends StatefulWidget {
  const TestDND({super.key});

  @override
  State<TestDND> createState() => _TestDNDState();
}

class _TestDNDState extends State<TestDND> {
  List<BlockNode> blockNodes = [];

  final _listViewKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  bool _isDragging = false;

  @override
  void initState() {
    super.initState();
    blockNodes = Data.blockNodes;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = Data.items(blockNodes);

    final blocksList = DragTarget<EditorItem>(
      onWillAccept: (data) {
        return true;
      },
      onAccept: (data) {
        _replaceBlock(data, blockNodes.length);
      },
      builder: (context, List<EditorItem?> footerCandidateData, rejectedData) {
        return ListView.builder(
          key: _listViewKey,
          controller: _scrollController,
          //initialItemCount: items.length + 1,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
          itemCount: items.length + 1,
          itemBuilder: (context, index) {
            if (index == items.length) {
              return DragTarget<EditorItem>(
                builder:
                    (context, List<EditorItem?> candidateData, rejectedData) {
                  return SizedBox(
                      height: 64,
                      child: candidateData.isNotEmpty ||
                              footerCandidateData.isNotEmpty
                          ? Container(
                              alignment: Alignment.topCenter,
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                              child: const _DragPlaceholder(0))
                          : null);
                },
                onWillAccept: (data) {
                  return true;
                },
                onAccept: (data) {
                  _replaceBlock(data, blockNodes.length);
                },
              );
            }

            return _ToggleListItem(
              items[index],
              //index: index,
              //animation: animation,
              onDragStart: () => _isDragging = true,
              onDragEnd: () => _isDragging = false,
              onReplaceBlock: _replaceBlock,
            );
          },
        );
      },
    );

    return Scaffold(
        appBar: AppBar(),
        body: Listener(
          onPointerMove: _onPointerMove,
          child: blocksList,
        ));
  }

  void _replaceBlock(EditorItem data, int blockIndex) {
    final indexFrom = data.blockNodeIndex;

    int blockIndexTo = indexFrom < blockIndex
        ? blockIndex - (data.children.length + 1)
        : blockIndex;

    if (indexFrom == blockIndexTo) {
      return;
    }

    int levelsToAdd = 0;
    if (blockIndexTo == 0) {
      levelsToAdd = -data.blockNode.listLevel;
    } else {
      final prevBlock = blockNodes[blockIndex - 1];
      levelsToAdd = prevBlock.listLevel +
          (prevBlock.isToggleList ? 1 : 0) -
          data.blockNode.listLevel;
    }

    setState(() {
      blockNodes.removeAt(indexFrom);
      for (final _ in data.children) {
        blockNodes.removeAt(indexFrom);
      }

      // _listViewKey.currentState?.removeItem(indexFrom, (_, __) => Container(),
      //     duration: Duration.zero);

      blockNodes.insert(blockIndexTo, data.blockNode.changeIndex(levelsToAdd));
      for (final child in data.children) {
        blockIndexTo++;
        blockNodes.insert(blockIndexTo, child.blockNode.changeIndex(levelsToAdd));
      }

      //_listViewKey.currentState?.insertItem(itemIndexTo);
      //TODO: fix replace
    });
  }

  void _onPointerMove(PointerMoveEvent event) {
    //print("x: ${event.position.dx}, y: ${event.position.dy}");

    if (!_isDragging) return;

    RenderBox render =
        _listViewKey.currentContext?.findRenderObject() as RenderBox;
    Offset position = render.localToGlobal(Offset.zero);
    double topY = position.dy;
    double bottomY = topY + render.size.height;

    // print("x: ${position.dy}, "
    //     "y: ${position.dy}, "
    //     "height: ${render.size.width}, "
    //     "width: ${render.size.height}");

    const detectedRange = 100;
    const moveDistance = 3;

    if (event.position.dy < topY + detectedRange &&
        _scrollController.offset > 0) {
      final double to = max(_scrollController.offset - moveDistance, 0);
      _scrollController.jumpTo(to);
    }
    if (event.position.dy > bottomY - detectedRange &&
        _scrollController.offset < _scrollController.position.maxScrollExtent) {
      final double to = min(_scrollController.offset + moveDistance,
          _scrollController.position.maxScrollExtent);
      _scrollController.jumpTo(to);
    }
  }
}

class _DragPlaceholder extends StatelessWidget {
  final int level;

  const _DragPlaceholder(this.level);

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 8,
      thickness: 2,
      color: Colors.blue,
      indent: level * 24,
      // endIndent: 16,
    );
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

class _ToggleListItem extends StatelessWidget {
  final EditorItem item;
  final Function() onDragStart;
  final Function() onDragEnd;
  final Animation<double>? animation;
  final Function(EditorItem, int) onReplaceBlock;

  const _ToggleListItem(this.item,
      {this.animation,
      required this.onReplaceBlock,
      required this.onDragStart,
      required this.onDragEnd});

  @override
  Widget build(BuildContext context) {
    Widget blockWidget = _BlockWidget(item.blockNode);

    if (item.isToggle) {
      blockWidget = ProgrammaticExpansionTile(
        title: Text(item.title),
        listKey: ValueKey(item.blockNodeIndex),
        //subtitle: subtitle,
        trailing: const SizedBox.shrink(),
        leading: const Icon(Icons.arrow_drop_down),
        disableTopAndBottomBorders: true,
        //backgroundColor: backgroundColor,
        initiallyExpanded: item.expanded,
        //onExpansionChanged: _onSetExpansion,
        key: ValueKey(item.blockNodeIndex),
        contentPadding: const EdgeInsets.all(0),
        children: item.children.map((child) {
          return _ToggleListItem(child,
              animation: animation,
              onReplaceBlock: onReplaceBlock,
              onDragStart: onDragStart,
              onDragEnd: onDragEnd);
        }).toList(),
      );

      // blockWidget = ExpansionTile(
      //   initiallyExpanded: item.expanded,
      //   leading: const Icon(Icons.arrow_drop_down),
      //   trailing: const SizedBox.shrink(),
      //     tilePadding: const EdgeInsets.all(0),
      //   title: Text(item.title),
      //   children: item.children.map((child) {
      //     return _ToggleListItem(child,
      //         animation: animation,
      //         onReplaceBlock: onReplaceBlock,
      //         onDragStart: onDragStart,
      //         onDragEnd: onDragEnd);
      //   }).toList(),
      // );
    }

    blockWidget = PageStorage(
      bucket: _pageStorageBucket,
      child: Material(child: Padding(
        padding: EdgeInsets.only(left: item.level * 24),
        child: blockWidget,
      )),
    );

    final draggableWidget = LongPressDraggable(
      data: item,
      feedback: Opacity(
          opacity: 0.5,
          child: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: blockWidget,
          )),
      // childWhenDragging:
      //     Opacity(opacity: 0.2, child: blockWidget),
      childWhenDragging: const SizedBox.shrink(),
      onDragStarted: onDragStart,
      onDragEnd: (details) => onDragEnd(),
      onDraggableCanceled: (velocity, offset) => onDragEnd(),
      child: blockWidget,
    );

    return SizeTransition(
      sizeFactor: animation ?? const AlwaysStoppedAnimation<double>(1),
      child: DragTarget<EditorItem>(
        builder: (context, List<EditorItem?> candidateData, rejectedData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (item.blockNodeIndex == 0) const SizedBox(height: 16),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: candidateData.isNotEmpty
                    ? _DragPlaceholder(item.blockNode.listLevel)
                    : const SizedBox.shrink(),
              ),
              draggableWidget,
            ],
          );
        },
        onWillAccept: (data) {
          return true;
        },
        onAccept: (data) {
          onReplaceBlock(data, item.blockNodeIndex);
        },
      ),
    );
  }
}
