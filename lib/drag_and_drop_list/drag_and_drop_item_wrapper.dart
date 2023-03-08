import 'drag_and_drop_builder_parameters.dart';
import 'drag_and_drop_item.dart';
import 'measure_size.dart';
import 'package:flutter/material.dart';

class DragAndDropItemWrapper extends StatefulWidget {
  final DragAndDropItem child;
  final DragAndDropBuilderParameters? parameters;

  const DragAndDropItemWrapper(
      {required this.child, required this.parameters, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DragAndDropItemWrapper();
}

class _DragAndDropItemWrapper extends State<DragAndDropItemWrapper>
    with TickerProviderStateMixin {
  DragAndDropItem? _hoveredDraggable;

  bool _dragging = false;
  Size _containerSize = Size.zero;

  @override
  Widget build(BuildContext context) {
    Widget draggable = MeasureSize(
      onSizeChange: _setContainerSize,
      child: LongPressDraggable<DragAndDropItem>(
        data: widget.child,
        axis: Axis.vertical,
        feedback: SizedBox(
          width: widget.parameters!.itemDraggingWidth ?? _containerSize.width,
          child: Material(
            color: Colors.transparent,
            child: Container(
              decoration: widget.parameters!.itemDecorationWhileDragging,
              child: Directionality(
                  textDirection: Directionality.of(context),
                  child: widget.child.feedbackWidget ?? widget.child.child),
            ),
          ),
        ),
        childWhenDragging: Container(),
        onDragStarted: () => _setDragging(true),
        onDragCompleted: () => _setDragging(false),
        onDraggableCanceled: (_, __) => _setDragging(false),
        onDragEnd: (_) => _setDragging(false),
        child: widget.child.child,
      ),
    );

    return Stack(
      children: <Widget>[
        Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: widget.parameters!.verticalAlignment,
          children: <Widget>[
            AnimatedSize(
              duration: Duration(
                  milliseconds: widget.parameters!.itemSizeAnimationDuration),
              alignment: Alignment.topLeft,
              child: _hoveredDraggable != null
                  ? Opacity(
                      opacity: widget.parameters!.itemGhostOpacity,
                      child: widget.parameters!.itemGhost ??
                          _hoveredDraggable!.child,
                    )
                  : Container(),
            ),
            Listener(
              onPointerMove: _onPointerMove,
              onPointerDown: widget.parameters!.onPointerDown,
              onPointerUp: widget.parameters!.onPointerUp,
              child: draggable,
            ),
          ],
        ),
        Positioned.fill(
          child: DragTarget<DragAndDropItem>(
            builder: (context, candidateData, rejectedData) {
              if (candidateData.isNotEmpty) {}
              return Container();
            },
            onWillAccept: (incoming) {
              bool accept = true;
              if (widget.parameters!.itemOnWillAccept != null) {
                accept = widget.parameters!.itemOnWillAccept!(
                    incoming, widget.child);
              }
              if (accept && mounted) {
                setState(() {
                  _hoveredDraggable = incoming;
                });
              }
              return accept;
            },
            onLeave: (incoming) {
              if (mounted) {
                setState(() {
                  _hoveredDraggable = null;
                });
              }
            },
            onAccept: (incoming) {
              if (mounted) {
                setState(() {
                  if (widget.parameters!.onItemReordered != null) {
                    widget.parameters!.onItemReordered!(incoming, widget.child);
                  }
                  _hoveredDraggable = null;
                });
              }
            },
          ),
        )
      ],
    );
  }

  void _setContainerSize(Size? size) {
    if (mounted) {
      setState(() {
        _containerSize = size!;
      });
    }
  }

  void _setDragging(bool dragging) {
    if (_dragging != dragging && mounted) {
      setState(() {
        _dragging = dragging;
      });
      if (widget.parameters!.onItemDraggingChanged != null) {
        widget.parameters!.onItemDraggingChanged!(widget.child, dragging);
      }
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_dragging) widget.parameters!.onPointerMove!(event);
  }
}
