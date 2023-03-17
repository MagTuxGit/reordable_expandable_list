import 'package:flutter/material.dart';

class ReordableTest extends StatefulWidget {
  const ReordableTest({super.key});

  @override
  State<ReordableTest> createState() => _ReordableTestState();
}

class _ReordableTestState extends State<ReordableTest> {
  List<String> blocks = List.generate(20, (index) => 'Block $index');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: ReorderableListView(
            onReorder: (int oldIndex, int newIndex) {
              setState(() {
                final item = blocks.removeAt(oldIndex);
                final indexTo = oldIndex < newIndex ? newIndex - 1 : newIndex;
                blocks.insert(indexTo, item);
              });
            },
            children: blocks.map((block) {
              return Material(
                key: ValueKey(block),
                color: Colors.transparent,
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                  child: Text(block),
                ),
              );
            }).toList(),
        ),
    );
  }
}
