import 'drag_and_drop_builder_parameters.dart';
import 'drag_and_drop_item.dart';
import 'package:flutter/material.dart';

abstract class DragAndDropListInterface {
  final List<DragAndDropItem>? children;

  DragAndDropListInterface({this.children});

  Widget generateWidget(DragAndDropBuilderParameters params);

  get isExpanded;

  toggleExpanded();

  expand();

  collapse();
}
