import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reordable Expandable'),
      ),
      body: ReorderableListView.builder(
        padding: EdgeInsets.only(
            bottom: BlockMenuOverlay.height(
                widget.bloc.blockMenuOverlayState()) +
                48),
        scrollController: _scrollController,
        onReorder: _onBlocksReordered,
        onReorderStart: _onReorderStart,
        onReorderEnd: _onReorderEnd,
        //TODO: use proxyDecorator to minimize the child
        proxyDecorator: (child, index, animation) =>
            _ReorderableListProxyDecorator(child, index, animation),
        header: Column(
          children: [
            Container(
              height: 6,
              margin: const EdgeInsets.only(bottom: 8),
              color: BrandColors.tileBorderColor(
                  state.tileStyle.colorType,
                  state.tileStyle.colorStyle),
            ),
          ],
        ),
        itemCount: state.items.length,
        itemBuilder: (context, index) {
          final item = state.items[index];
          return Container(
            key: ValueKey(item.blockNode.widgetKey),
            child: BlockWidget(
              blockNode: item.blockNode,
              tileStyle: state.tileStyle,
              listIndex: index,
              scrollController: _scrollController,
              bloc: widget.bloc,
              isSelectModeOn: state.isSelectModeOn(),
              hasEditors: state.hasEditors,
              onOpenInnerLink: widget.onOpenInnerLink,
              onQuillFocusChanged: _onQuillFocusChanged,
              onSimpleFocusChanged: _onSimpleFocusChanged,
              onQuillUpdate: _onQuillUpdate,
              onTextUpdate: _onTextUpdate,
              onSplitBlock: widget.bloc.splitBlock,
              onJoinBlock: widget.bloc.joinBlock,
              onCheckboxClicked: widget.bloc.checkboxClicked,
              onClipboardPaste: widget.bloc.onClipboardPaste,
              onConvertBlock: widget.bloc.blockChangeType,
            ),
          );
        },
      ),
    );
  }
}
