import 'package:flutter/material.dart';

import 'model.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<BlockNode> blockNodes = [];

  @override
  void initState() {
    super.initState();
    blockNodes = Data.blockNodes;
  }

  @override
  Widget build(BuildContext context) {
    final items = Data.items(blockNodes);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reordable Expandable'),
      ),
      body: ReorderableListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            key: ValueKey(item.blockNode.id),
            child: ListTile(title: Text(item.blockNode.value)),
          );
        },
        onReorder: (int oldIndex, int newIndex) {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            if (oldIndex == newIndex) return;

            assert(oldIndex > -1 &&
                oldIndex < blockNodes.length &&
                newIndex > -1 &&
                newIndex < blockNodes.length);

            final node = blockNodes.removeAt(oldIndex);
            blockNodes.insert(newIndex, node);
          });
        },
      ),
    );
  }
}
