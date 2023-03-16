import 'drag_and_drop_builder_parameters.dart';
import 'drag_and_drop_list_interface.dart';
import 'package:flutter/material.dart';

class DragAndDropListWrapper extends StatefulWidget {
  final DragAndDropListInterface dragAndDropList;
  final DragAndDropBuilderParameters parameters;

  const DragAndDropListWrapper(
      {required this.dragAndDropList, required this.parameters, Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DragAndDropListWrapper();
}

class _DragAndDropListWrapper extends State<DragAndDropListWrapper>
    with TickerProviderStateMixin {
  DragAndDropListInterface? _hoveredDraggable;

  bool _dragging = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Widget dragAndDropListContents =
        widget.dragAndDropList.generateWidget(widget.parameters);

    Widget draggable = LongPressDraggable<DragAndDropListInterface>(
      data: widget.dragAndDropList,
      axis: Axis.vertical,
      feedback: buildFeedbackWithoutHandle(context, dragAndDropListContents),
      childWhenDragging: Container(),
      onDragStarted: () => _setDragging(true),
      onDragCompleted: () => _setDragging(false),
      onDraggableCanceled: (_, __) => _setDragging(false),
      onDragEnd: (_) => _setDragging(false),
      child: dragAndDropListContents,
    );

    final stack = Stack(
      children: <Widget>[
        Column(
          children: [
            AnimatedSize(
              duration: Duration(
                  milliseconds: widget.parameters.listSizeAnimationDuration),
              alignment: Alignment.bottomCenter,
              child: _hoveredDraggable != null
                  ? Opacity(
                      opacity: widget.parameters.listGhostOpacity,
                      child: widget.parameters.listGhost ??
                          Container(
                            padding: const EdgeInsets.all(0),
                            child: _hoveredDraggable!
                                .generateWidget(widget.parameters),
                          ),
                    )
                  : Container(),
            ),
            Listener(
              onPointerMove: _onPointerMove,
              onPointerDown: widget.parameters.onPointerDown,
              onPointerUp: widget.parameters.onPointerUp,
              child: draggable,
            ),
          ],
        ),
        Positioned.fill(
          child: DragTarget<DragAndDropListInterface>(
            builder: (context, candidateData, rejectedData) {
              if (candidateData.isNotEmpty) {}
              return IgnorePointer(
                child: Container(
                  decoration: BoxDecoration(
                      color: Colors.transparent,
                      border: Border.all(color: Colors.green, width: 3)),
                ),
              );
            },
            onWillAccept: (incoming) {
              bool accept = true;
              if (widget.parameters.listOnWillAccept != null) {
                accept = widget.parameters.listOnWillAccept!(
                    incoming, widget.dragAndDropList);
              }
              if (accept && mounted) {
                setState(() {
                  _hoveredDraggable = incoming;
                });
              }
              return accept;
            },
            onLeave: (incoming) {
              if (_hoveredDraggable != null) {
                if (mounted) {
                  setState(() {
                    _hoveredDraggable = null;
                  });
                }
              }
            },
            onAccept: (incoming) {
              if (mounted) {
                setState(() {
                  widget.parameters.onListReordered!(
                      incoming, widget.dragAndDropList);
                  _hoveredDraggable = null;
                });
              }
            },
          ),
        ),
      ],
    );

    Widget toReturn = stack;
    if (widget.parameters.listPadding != null) {
      toReturn = Padding(
        padding: widget.parameters.listPadding!,
        child: stack,
      );
    }

    return toReturn;
  }

  Widget buildFeedbackWithoutHandle(
      BuildContext context, Widget dragAndDropListContents) {
    return SizedBox(
      width: widget.parameters.listDraggingWidth ??
          MediaQuery.of(context).size.width,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: widget.parameters.listDecorationWhileDragging,
          child: Directionality(
            textDirection: Directionality.of(context),
            child: dragAndDropListContents,
          ),
        ),
      ),
    );
  }

  void _setDragging(bool dragging) {
    if (_dragging != dragging && mounted) {
      setState(() {
        _dragging = dragging;
      });
      if (widget.parameters.onListDraggingChanged != null) {
        widget.parameters.onListDraggingChanged!(
            widget.dragAndDropList, dragging);
      }
    }
  }

  void _onPointerMove(PointerMoveEvent event) {
    if (_dragging) widget.parameters.onPointerMove!(event);
  }
}
