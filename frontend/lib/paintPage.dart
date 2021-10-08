import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';

import 'Classes/DrawingModel.dart';
import 'Classes/DrawingPainter.dart';

class paintPage extends StatefulWidget {
  const paintPage({Key key}) : super(key: key);

  @override
  _paintPageState createState() => _paintPageState();
}

class _paintPageState extends State<paintPage> {
  // ignore: deprecated_member_use
  List<DrawModel> pointsList = List();

  // ignore: close_sinks
  final pointsStream = BehaviorSubject<List<DrawModel>>();
  GlobalKey key = GlobalKey();
  bool contiguous = true;
  @override
  void dispose() {
    pointsStream.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: key,
      body: GestureDetector(
        onPanStart: (details) {
          Paint paint = Paint();
          paint.color = Colors.red;
          paint.strokeWidth = 3.0;
          paint.strokeCap = StrokeCap.round;
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          pointsList.add(DrawModel(
              offset: renderBox.globalToLocal(details.globalPosition),
              paint: paint));
          pointsStream.add(pointsList);
        },
        onPanUpdate: (details) {
          Paint paint = Paint();
          paint.color = Colors.red;
          paint.strokeWidth = 3.0;
          paint.strokeCap = StrokeCap.round;
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          pointsList.add(DrawModel(
              offset: renderBox.globalToLocal(details.globalPosition),
              paint: paint));
          pointsStream.add(pointsList);
        },
        onPanEnd: (details) {
          if (contiguous) {
            pointsList.add(null);
            pointsStream.add(pointsList);
          }
        },
        child: Container(
          color: Colors.black,
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height,
          child: StreamBuilder<List<DrawModel>>(
              stream: pointsStream,
              builder: (context, snapshot) {
                return CustomPaint(
                  painter: DrawingPainter(pointsList: snapshot.data ?? []),
                );
              }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          pointsList.add(null);
          contiguous = !contiguous;
        },
      ),
    );
  }
}
