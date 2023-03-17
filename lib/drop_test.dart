import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

class TestDND extends StatefulWidget {
  const TestDND({super.key});

  @override
  State<TestDND> createState() => _TestDNDState();
}

class _TestDNDState extends State<TestDND> {
  List<String> blocks = List.generate(20, (index) => 'Block $index');

  final _listViewKey = GlobalKey();
  final ScrollController _scrollController = ScrollController();
  bool _isDragging = false;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final blocksList = CustomScrollView(
      key: _listViewKey,
      controller: _scrollController,
      slivers: [
        SliverToBoxAdapter(
            child: SizedBox(
                height: 44,
                child: DragTarget<String>(
                  builder:
                      (context, List<String?> candidateData, rejectedData) {
                    if (candidateData.isNotEmpty) {
                      return const Align(
                          alignment: Alignment.bottomCenter,
                          child: Divider(thickness: 2, color: Colors.blue));
                    }
                    return const SizedBox.shrink();
                  },
                  onWillAccept: (data) {
                    return true;
                  },
                  onAccept: (data) {
                    setState(() {
                      final indexFrom = blocks.indexOf(data);
                      blocks.removeAt(indexFrom);

                      blocks.insert(0, data);
                    });
                  },
                ))),
        ...blocks.mapIndexed((index, block) {
          final blockWidget = Material(
            color: Colors.transparent,
            child: Container(
              height: 44,
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Text(block),
            ),
          );

          return SliverToBoxAdapter(
            child: DragTarget<String>(
              builder: (context, List<String?> candidateData, rejectedData) {
                final draggableWidget = LongPressDraggable(
                  data: block,
                  axis: Axis.vertical,
                  feedback:
                      Opacity(opacity: 0.3, child: blockWidget),
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
                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      child: SizedBox(
                        height: candidateData.isNotEmpty ? null : 0,
                        child: Visibility(
                            visible: candidateData.isNotEmpty,
                            child: const Divider(
                              height: 8,
                              thickness: 2,
                              color: Colors.blue,
                              indent: 16,
                              endIndent: 16,
                            )),
                      ),
                    ),
                    draggableWidget,
                  ],
                );
              },
              onWillAccept: (data) {
                return true;
              },
              onAccept: (data) {
                setState(() {
                  final indexFrom = blocks.indexOf(data);
                  blocks.removeAt(indexFrom);

                  final indexTo = indexFrom < index ? index - 1 : index;
                  blocks.insert(indexTo, data);
                });
              },
            ),
          );
        }),
        SliverToBoxAdapter(
          child: SizedBox(
            height: 64,
            child: DragTarget<String>(
              builder: (context, List<String?> candidateData, rejectedData) {
                if (candidateData.isNotEmpty) {
                  return const Align(
                      alignment: Alignment.topCenter,
                      child: Divider(thickness: 2, color: Colors.blue));
                }
                return const SizedBox.shrink();
              },
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
            ),
          ),
        ),
        SliverFillRemaining(
          hasScrollBody: false,
          child: DragTarget<String>(
            builder: (context, List<String?> candidateData, rejectedData) {
              if (candidateData.isNotEmpty) {
                return const Align(
                    alignment: Alignment.topCenter,
                    child: Divider(thickness: 2, color: Colors.blue));
              }
              return const SizedBox.shrink();
            },
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
          ),
        ),
      ],
    );

    return Scaffold(
        appBar: AppBar(),
        body: Listener(
          onPointerMove: (PointerMoveEvent event) {
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
                _scrollController.offset <
                    _scrollController.position.maxScrollExtent) {
              final double to = min(_scrollController.offset + moveDistance,
                  _scrollController.position.maxScrollExtent);
              _scrollController.jumpTo(_scrollController.offset + moveDistance);
            }
          },
          child: blocksList,
        ));
  }
}
