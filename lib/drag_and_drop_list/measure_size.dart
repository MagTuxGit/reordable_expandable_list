import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef OnWidgetSizeChange = void Function(Size? size);

class MeasureSize extends StatefulWidget {
  final Widget? child;
  final OnWidgetSizeChange onSizeChange;

  const MeasureSize({
    Key? key,
    required this.onSizeChange,
    required this.child,
  }) : super(key: key);

  @override
  State createState() => _MeasureSizeState();
}

class _MeasureSizeState extends State<MeasureSize> {
  @override
  Widget build(BuildContext context) {
    SchedulerBinding.instance.addPostFrameCallback(postFrameCallback);
    return Container(
      key: widgetKey,
      child: widget.child,
    );
  }

  var widgetKey = GlobalKey();
  Size? oldSize;
  var topLeftPosition = Offset.zero;

  void postFrameCallback(_) {
    var context = widgetKey.currentContext;
    if (context == null) return;

    var newSize = context.size;
    if (oldSize != newSize) {
      widget.onSizeChange(newSize);
      oldSize = newSize;
    }
  }
}
