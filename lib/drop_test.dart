import 'package:flutter/material.dart';

class TestDND extends StatefulWidget {
  const TestDND({super.key});

  @override
  State<TestDND> createState() => _TestDNDState();
}

class _TestDNDState extends State<TestDND> {
  bool isSuccessful = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(height: 44),
          Opacity(
            opacity: isSuccessful ? 0 : 1,
            child: const LongPressDraggable(
              data: 'Flutter',
              axis: Axis.vertical,
              feedback: FlutterLogo(size: 100),
              childWhenDragging:
                  Opacity(opacity: 0.2, child: FlutterLogo(size: 100)),
              child: FlutterLogo(size: 100),
            ),
          ),
          const SizedBox(height: 200),
          DragTarget(
            builder: (context, List<String?> candidateData, rejectedData) {
              return Center(
                child: isSuccessful
                    ? Container(
                        color: Colors.yellow,
                        height: 200.0,
                        width: 200.0,
                        child: const Center(child: FlutterLogo(size: 100)),
                      )
                    : Container(
                        height: 200.0,
                        width: 200.0,
                        decoration: BoxDecoration(
                            color: Colors.yellow,
                            border: candidateData.isNotEmpty
                                ? Border.all(color: Colors.red, width: 3)
                                : null),
                      ),
              );
            },
            onWillAccept: (data) {
              return true;
            },
            onAccept: (data) {
              setState(() {
                isSuccessful = true;
              });
            },
            // onLeave: (data) {
            //   print('leave');
            // },
            // onMove: (data) {
            //   print('move');
            // },
          ),
          const Spacer(),
          Center(
            child: MaterialButton(
                child: const Text('Reset'),
                onPressed: () {
                  setState(() {
                    isSuccessful = false;
                  });
                }),
          ),
        ],
      ),
    );
  }
}
