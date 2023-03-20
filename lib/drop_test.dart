import 'dart:math';

import 'package:flutter/material.dart';

import 'model.dart';

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
    final blocksList = DragTarget<BlockNode>(
      onWillAccept: (data) {
        return true;
      },
      onAccept: (data) {
        setState(() {
          final indexFrom = blockNodes.indexOf(data);
          blockNodes.removeAt(indexFrom);

          final indexTo = blockNodes.length;
          blockNodes.insert(indexTo, data);
        });
      },
      builder: (context, List<BlockNode?> footerCandidateData, rejectedData) {
        return AnimatedList(
          key: _listViewKey,
          controller: _scrollController,
          initialItemCount: blockNodes.length + 1,
          itemBuilder: (context, index, animation) {
            if (index == blockNodes.length) {
              return DragTarget<BlockNode>(
                builder:
                    (context, List<BlockNode?> candidateData, rejectedData) {
                  return SizedBox(
                      height: 64,
                      child: candidateData.isNotEmpty ||
                              footerCandidateData.isNotEmpty
                          ? const Align(
                              alignment: Alignment.topCenter,
                              child: _DragPlaceholder())
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

            final block = blockNodes[index];

            final blockWidget = _BlockWidget(block);

            final draggableWidget = LongPressDraggable(
              data: block,
              axis: Axis.vertical,
              feedback: Opacity(opacity: 0.5, child: blockWidget),
              // childWhenDragging:
              //     Opacity(opacity: 0.2, child: blockWidget),
              childWhenDragging: const SizedBox.shrink(),
              onDragStarted: () => _isDragging = true,
              onDragEnd: (details) => _isDragging = false,
              onDraggableCanceled: (velocity, offset) =>
              _isDragging = false,
              child: blockWidget,
            );

            return SizeTransition(
              sizeFactor: animation,
              child: DragTarget<BlockNode>(
                builder:
                    (context, List<BlockNode?> candidateData, rejectedData) {
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (index == 0) const SizedBox(height: 16),
                        AnimatedSize(
                          duration: const Duration(milliseconds: 200),
                          child: candidateData.isNotEmpty
                              ? const _DragPlaceholder()
                              : const SizedBox.shrink(),
                        ),
                        draggableWidget,
                      ],
                    ),
                  );
                },
                onWillAccept: (data) {
                  return true;
                },
                onAccept: (data) {
                  _replaceBlock(data, index);
                },
              ),
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

  void _replaceBlock(BlockNode data, int index) {
    setState(() {
      final indexFrom = blockNodes.indexOf(data);
      blockNodes.removeAt(indexFrom);
      _listViewKey.currentState?.removeItem(indexFrom, (_, __) => Container(),
          duration: Duration.zero);

      final indexTo = indexFrom < index ? index - 1 : index;
      blockNodes.insert(indexTo, data);
      _listViewKey.currentState?.insertItem(indexTo);
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
  const _DragPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Divider(
      height: 8,
      thickness: 2,
      color: Colors.blue,
      indent: 16,
      endIndent: 16,
    );
  }
}

class _BlockWidget extends StatelessWidget {
  final BlockNode blockNode;

  const _BlockWidget(this.blockNode);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Padding(
        padding: EdgeInsets.only(left: blockNode.listLevel * 24),
        child: Row(
          children: [
            if (blockNode.isToggleList)
              const Icon(Icons.arrow_drop_down),
            Container(
              height: 44,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 4),
              child: Text(blockNode.value),
            ),
          ],
        ),
      ),
    );
  }
}
