import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
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
  io.Socket socket;
  // ignore: close_sinks
  final pointsStream = BehaviorSubject<List<DrawModel>>();
  GlobalKey key = GlobalKey();
  bool contiguous = true;

  @override
  void initState() {
    super.initState();
    ConnectIO();
  }

  void ConnectIO() async {
    socket = io.io("http://127.0.0.1:2000", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    socket.on('connect', (data) => print("connected"));
    print(socket.connected);
  }

  @override
  void dispose() {
    pointsStream.close();
    super.dispose();
  }

  void emitCoordinates(DrawModel model) {
    socket.emit('coordinates', model.offset);
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
          DrawModel model = DrawModel(
              offset: renderBox.globalToLocal(details.globalPosition),
              paint: paint);
          // emitCoordinates(model);
          pointsList.add(model);
          pointsStream.add(pointsList);
          emitCoordinates(model);
        },
        onPanUpdate: (details) {
          Paint paint = Paint();
          paint.color = Colors.red;
          paint.strokeWidth = 3.0;
          paint.strokeCap = StrokeCap.round;
          RenderBox renderBox = context.findRenderObject() as RenderBox;
          DrawModel model = DrawModel(
              offset: renderBox.globalToLocal(details.globalPosition),
              paint: paint);
          // emitCoordinates(model);
          pointsList.add(model);
          pointsStream.add(pointsList);
          emitCoordinates(model);
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
