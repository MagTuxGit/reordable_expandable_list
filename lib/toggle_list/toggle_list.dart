import 'dart:math';

import 'package:flutter/material.dart';

import 'programmatic_expansion_tile.dart';

final PageStorageBucket _pageStorageBucket = PageStorageBucket();

class ToggleList<T> extends StatefulWidget {
  final List<ToggleItem<T>> items;
  final Function(ToggleItem<T>) onReplaceToEnd;
  final Function(ToggleItem<T>, int) onReplace;
  final Widget Function(T) nodeBuilder;

  const ToggleList(
      {required this.items,
      required this.nodeBuilder,
      required this.onReplaceToEnd,
      required this.onReplace,
      super.key});

  @override
  State<ToggleList> createState() => _ToggleListState<T>();
}

class _ToggleListState<T> extends State<ToggleList<T>> {
  List<ToggleItem<T>> get items => widget.items;
  final ScrollController _scrollController = ScrollController();
  bool _isDragging = false;

  final _listViewKey = GlobalKey<AnimatedListState>();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerMove: _onPointerMove,
      child: DragTarget<ToggleItem<T>>(
        onWillAccept: (data) {
          return true;
        },
        onAccept: (data) {
          widget.onReplaceToEnd(data);
        },
        builder:
            (context, List<ToggleItem<T>?> footerCandidateData, rejectedData) {
          return ListView.builder(
            key: _listViewKey,
            controller: _scrollController,
            //initialItemCount: items.length + 1,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            itemCount: items.length + 1,
            itemBuilder: (context, index) {
              if (index == items.length) {
                return DragTarget<ToggleItem<T>>(
                  builder: (context, List<ToggleItem<T>?> candidateData,
                      rejectedData) {
                    return SizedBox(
                        height: 64,
                        child: candidateData.isNotEmpty ||
                                footerCandidateData.isNotEmpty
                            ? Container(
                                alignment: Alignment.topCenter,
                                padding:
                                    const EdgeInsets.fromLTRB(16, 0, 16, 0),
                                child: const _DragPlaceholder(0))
                            : null);
                  },
                  onWillAccept: (data) {
                    return true;
                  },
                  onAccept: (data) {
                    widget.onReplaceToEnd(data);
                  },
                );
              }

              return _ToggleListItem<T>(
                items[index],
                //index: index,
                //animation: animation,
                onDragStart: () => _isDragging = true,
                onDragEnd: () => _isDragging = false,
                onReplaceBlock: widget.onReplace,
                nodeBuilder: widget.nodeBuilder,
              );
            },
          );
        },
      ),
    );
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

class _ToggleListItem<T> extends StatelessWidget {
  final ToggleItem<T> item;
  final Function() onDragStart;
  final Function() onDragEnd;
  final Animation<double>? animation;
  final Function(ToggleItem<T>, int) onReplaceBlock;
  final Widget Function(T) nodeBuilder;

  const _ToggleListItem(
    this.item, {
    this.animation,
    required this.nodeBuilder,
    required this.onReplaceBlock,
    required this.onDragStart,
    required this.onDragEnd,
  });

  @override
  Widget build(BuildContext context) {
    Widget blockWidget = nodeBuilder(item.node);

    if (item.isToggle) {
      blockWidget = ProgrammaticExpansionTile(
        title: blockWidget,
        listKey: ValueKey(item.nodeIndex),
        //subtitle: subtitle,
        trailing: const SizedBox.shrink(),
        leading: const Icon(Icons.arrow_drop_down),
        disableTopAndBottomBorders: true,
        //backgroundColor: backgroundColor,
        //initiallyExpanded: item.expanded,
        //onExpansionChanged: _onSetExpansion,
        key: ValueKey(item.nodeIndex),
        contentPadding: const EdgeInsets.all(0),
        children: item.children.map((child) {
          return _ToggleListItem(
            child,
            animation: animation,
            onReplaceBlock: onReplaceBlock,
            onDragStart: onDragStart,
            onDragEnd: onDragEnd,
            nodeBuilder: nodeBuilder,
          );
        }).toList(),
      );
    }

    blockWidget = PageStorage(
      bucket: _pageStorageBucket,
      child: Material(
        child: Padding(
          padding: EdgeInsets.only(left: item.level * 24),
          child: blockWidget,
        ),
      ),
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
      child: DragTarget<ToggleItem<T>>(
        builder: (context, List<ToggleItem<T>?> candidateData, rejectedData) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (item.nodeIndex == 0) const SizedBox(height: 16),
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                child: candidateData.isNotEmpty
                    ? _DragPlaceholder(item.level)
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
          onReplaceBlock(data, item.nodeIndex);
        },
      ),
    );
  }
}

class ToggleItem<T> {
  final T node;
  final int nodeIndex;
  final int level;
  final bool isToggle;
  final ToggleItem<T>? parent;
  final List<ToggleItem<T>> children;

  ToggleItem({
    required this.node,
    required this.nodeIndex,
    required this.level,
    required this.isToggle,
    required this.parent,
    required this.children,
  });

  void add(ToggleItem<T> child) {
    children.add(child);
  }
}
