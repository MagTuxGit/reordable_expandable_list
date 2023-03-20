import 'dart:math';

import 'package:flutter/material.dart';

class TestDND extends StatefulWidget {
  const TestDND({super.key});

  @override
  State<TestDND> createState() => _TestDNDState();
}

class _TestDNDState extends State<TestDND> {
  List<String> blocks = List.generate(20, (index) => 'Block $index');

  final _listViewKey = GlobalKey<AnimatedListState>();
  final ScrollController _scrollController = ScrollController();
  bool _isDragging = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocksList = DragTarget<String>(
      onWillAccept: (data) {
        return true;
      },
      onAccept: (data) {
        setState(() {
          final indexFrom = blocks.indexOf(data);
          blocks.removeAt(indexFrom);

          final indexTo = blocks.length;
          blocks.insert(indexTo, data);
        });
      },
      builder: (context, List<String?> footerCandidateData, rejectedData) {
        return AnimatedList(
          key: _listViewKey,
          controller: _scrollController,
          initialItemCount: blocks.length + 1,
          itemBuilder: (context, index, animation) {
            if (index == blocks.length) {
              return DragTarget<String>(
                builder: (context, List<String?> candidateData, rejectedData) {
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
                  _replaceBlock(data, blocks.length);
                },
              );
            }

            final block = blocks[index];

            final blockWidget = Material(
              color: Colors.transparent,
              child: Container(
                height: 44,
                alignment: Alignment.centerLeft,
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                child: Text(block),
              ),
            );

            return SizeTransition(
              sizeFactor: animation,
              // position: animation.drive(
              //   Tween(begin: const Offset(1.0, 0.0), end: const Offset(0.0, 0.0)),
              // ),
              child: DragTarget<String>(
                builder: (context, List<String?> candidateData, rejectedData) {
                  final draggableWidget = LongPressDraggable(
                    data: block,
                    axis: Axis.vertical,
                    feedback: Opacity(opacity: 0.5, child: blockWidget),
                    //feedback: blockWidget,
                    // childWhenDragging:
                    //     Opacity(opacity: 0.2, child: blockWidget),
                    childWhenDragging: const SizedBox.shrink(),
                    onDragStarted: () => _isDragging = true,
                    onDragEnd: (details) => _isDragging = false,
                    onDraggableCanceled: (velocity, offset) =>
                        _isDragging = false,
                    child: blockWidget,
                  );

                  return Column(
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

  void _replaceBlock(String data, int index) {
    setState(() {
      final indexFrom = blocks.indexOf(data);
      blocks.removeAt(indexFrom);
      _listViewKey.currentState?.removeItem(indexFrom, (_, __) => Container(),
          duration: Duration.zero);

      final indexTo = indexFrom < index ? index - 1 : index;
      blocks.insert(indexTo, data);
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
