import 'dart:core';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ProviderScope(child: MyAppState()));
}

var widgetMoveProvider = ChangeNotifierProvider<WidgetMoveProvider>((ref) => WidgetMoveProvider());

class WidgetMove extends ConsumerWidget {
  final WidgetMoveDataModel widgetMove;
  final VoidCallback refresh;
  const WidgetMove(this.widgetMove, this.refresh, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
        top: widgetMove.offset.dy,
        left: widgetMove.offset.dx,
        child: Draggable(
          childWhenDragging: Container(),
          feedback: Container(
            width: widgetMove.size.width,
            height: widgetMove.size.height,
            color: Colors.red,
            // child: Center(child: Text("x: ${offset.dx.toString()}, y: ${offset.dy.toString()}")),
          ),
          onDragEnd: (delta) {
            widgetMove.offset = delta.offset;
            refresh();
          },
          child: Container(
            width: widgetMove.size.width,
            height: widgetMove.size.height,
            color: Colors.red,
            child: Stack(
              children: [
                Positioned.fill(child: Center(child: Text("x: ${widgetMove.offset.dx.toString()}, y: ${widgetMove.offset.dy.toString()}"))),
                Positioned(
                    bottom: -2,
                    right: -2,
                    child: Draggable(
                      feedback: Container(
                        height: 10,
                        width: 10,
                        color: Colors.blue,
                      ),
                      childWhenDragging: Container(
                        height: 10,
                        width: 10,
                        color: Colors.blue,
                      ),
                      onDragEnd: (delta) {
                        Offset offset = delta.offset - (widgetMove.offset);

                        print("x: ${offset.dx.toString()}, y: ${offset.dy.toString()}");
                        widgetMove.size = Size(offset.dx + 20, offset.dy + 20);
                        refresh();
                      },
                      child: Container(
                        height: 10,
                        width: 10,
                        color: Colors.blue,
                      ),
                    ))
              ],
            ),
          ),
        ));
  }
}

class WidgetMoveDataModel {
  Offset offset;
  Size size = Size(100, 100);
  WidgetMoveDataModel({
    required this.offset,
    Size? size,
  }) {
    size = size;
  }
}

class WidgetMoveProvider extends ChangeNotifier {
  List<WidgetMoveDataModel> noteWidgets = [];
  List<WidgetMoveDataModel> tempWidgets = [];

  WidgetMoveProvider() {
    noteWidgets = [];
    tempWidgets = [];
  }

  void backUpList() {
    tempWidgets.clear();
    for (int i = 0; i < noteWidgets.length; i++) {
      tempWidgets.add(WidgetMoveDataModel(offset: noteWidgets[i].offset, size: noteWidgets[i].size));
    }
  }

  void addNoteWidget() {
    WidgetMoveDataModel newWidget = WidgetMoveDataModel(offset: Offset(20, 20));
    noteWidgets.add(newWidget);
    notifyListeners();
  }

  void horizontalArrange() {
    backUpList();
    double previousWidth = 0;
    for (int i = 0; i < noteWidgets.length; i++) {
      noteWidgets[i].offset = Offset(20 + previousWidth, 20);
      previousWidth += noteWidgets[i].size.width + 20;
    }
    notifyListeners();
  }

  void verticalArrange() {
    backUpList();
    double previousHeight = 0;
    for (int i = 0; i < noteWidgets.length; i++) {
      noteWidgets[i].offset = Offset(20, 20 + previousHeight);
      previousHeight += noteWidgets[i].size.height + 20;
    }
    notifyListeners();
  }

  void previousState() {
    for (int i = 0; i < noteWidgets.length; i++) {
      noteWidgets[i].offset = tempWidgets[i].offset;
      noteWidgets[i].size = tempWidgets[i].size;
    }
    notifyListeners();
  }

  void clear() {
    noteWidgets.clear();
    tempWidgets.clear();
    notifyListeners();
  }

  void refresh() {
    print("refresh");
    notifyListeners();
  }
}

class MyAppState extends ConsumerWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var provide = ref.watch(widgetMoveProvider);
    return MaterialApp(
      home: Scaffold(
        body: Column(
          children: [
            Expanded(
                flex: 9,
                child: Stack(
                    fit: StackFit.expand,
                    children: provide.noteWidgets.map((e) => WidgetMove(e, ref.read(widgetMoveProvider).refresh)).toList())),
            Flexible(
                flex: 1,
                child: Row(
                  children: [
                    MaterialButton(
                      onPressed: () {
                        ref.read(widgetMoveProvider).horizontalArrange();
                      },
                      child: Text("Horizontal"),
                    ),
                    MaterialButton(
                      onPressed: () {
                        ref.read(widgetMoveProvider).verticalArrange();
                      },
                      child: Text("Verticle"),
                    ),
                    MaterialButton(
                      onPressed: () {
                        ref.read(widgetMoveProvider).previousState();
                      },
                      child: Text("Previous State"),
                    ),
                    MaterialButton(
                      onPressed: () {
                        ref.read(widgetMoveProvider).clear();
                      },
                      child: Text("Clear"),
                    ),
                    MaterialButton(
                      onPressed: () {
                        ref.read(widgetMoveProvider).refresh();
                      },
                      child: Text("Refresh"),
                    )
                  ],
                ))
          ],
        ),
        floatingActionButton: FloatingActionButton(onPressed: () {
          provide.addNoteWidget();
        }),
      ),
    );
  }
}
