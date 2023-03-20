import 'drag_and_drop_builder_parameters.dart';
import 'drag_and_drop_list_interface.dart';
import 'package:flutter/material.dart';

typedef OnDropOnLastTarget = void Function(
  DragAndDropListInterface newOrReordered,
  DragAndDropListTarget receiver,
);

class DragAndDropListTarget extends StatefulWidget {
  final Widget? child;
  final DragAndDropBuilderParameters parameters;
  final OnDropOnLastTarget onDropOnLastTarget;
  final double lastListTargetSize;

  const DragAndDropListTarget(
      {this.child,
      required this.parameters,
      required this.onDropOnLastTarget,
      this.lastListTargetSize = 110,
      Key? key})
      : super(key: key);

  @override
  State<StatefulWidget> createState() => _DragAndDropListTarget();
}

class _DragAndDropListTarget extends State<DragAndDropListTarget>
    with TickerProviderStateMixin {
  DragAndDropListInterface? _hoveredDraggable;

  @override
  Widget build(BuildContext context) {
    Widget visibleContents = Column(
      children: <Widget>[
        AnimatedSize(
          duration: Duration(
              milliseconds: widget.parameters.listSizeAnimationDuration),
          alignment: Alignment.bottomCenter,
          child: _hoveredDraggable != null
              ? Opacity(
                  opacity: widget.parameters.listGhostOpacity,
                  child: widget.parameters.listGhost ??
                      _hoveredDraggable!.generateWidget(widget.parameters),
                )
              : Container(),
        ),
        widget.child ?? SizedBox(height: widget.lastListTargetSize),
      ],
    );

    if (widget.parameters.listPadding != null) {
      visibleContents = Padding(
        padding: widget.parameters.listPadding!,
        child: visibleContents,
      );
    }

    return Stack(
      children: <Widget>[
        visibleContents,
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
              if (widget.parameters.listTargetOnWillAccept != null) {
                accept =
                    widget.parameters.listTargetOnWillAccept!(incoming, widget);
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
                  widget.onDropOnLastTarget(incoming, widget);
                  _hoveredDraggable = null;
                });
              }
            },
          ),
        ),
      ],
    );
  }
}
