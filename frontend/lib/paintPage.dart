import 'dart:convert';
import 'dart:ffi';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Classes/TransferModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'Classes/DrawingModel.dart';
import 'Classes/DrawingPainter.dart';
import 'dart:io';
import 'dart:ui';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import 'Classes/User.dart';

class paintPage extends StatefulWidget {
  paintPage({this.roomID});
  String roomID;
  @override
  _paintPageState createState() => _paintPageState();
}

enum SelectedMode { StrokeWidth, Opacity, Color }

class _paintPageState extends State<paintPage> {
  // ignore: deprecated_member_use
  List<DrawModel> pointsList = List();
  // ignore: deprecated_member_use
  List<UserB> currentUsers = [];
  io.Socket socket;
  Color selectedColor = Colors.white;
  Color pickerColor = Colors.white;
  double strokeWidth = 3.0;
  bool showBottomList = false;
  double opacity = 1.0;
  FirebaseAuth auth = FirebaseAuth.instance;
  SelectedMode selectedMode = SelectedMode.StrokeWidth;
  // ignore: close_sinks
  final pointsStream = BehaviorSubject<List<DrawModel>>();
  // ignore: close_sinks
  final userStream = BehaviorSubject<List<UserB>>();
  GlobalKey key = GlobalKey();
  bool contiguous = true;
  List<Color> colors = [
    Colors.red,
    Colors.green,
    Colors.blue,
    Colors.amber,
    Colors.black
  ];

  @override
  void initState() {
    super.initState();
    ConnectIO();
  }

  Color getContigousStatus() {
    if (contiguous) {
      return Colors.transparent;
    } else {
      return Colors.white;
    }
  }

  void ConnectIO() async {
    socket = io
        .io("http://127.0.0.1:2000/?roomID=${widget.roomID}", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    socket.on('connect', (data) {
      print("connected");
      var userData = {
        'email': auth.currentUser.email,
        'username': auth.currentUser.displayName,
        'photoURL': auth.currentUser.photoURL,
        'room': widget.roomID
      };
      socket.emit('joinRoom', userData);
    });

    socket.on('roomUsers', (data) {
      print("getting users");
      print(data);
      if (data != null) {
        List<UserB> newUsers = [];
        var userArray = data['users'] as List<dynamic>;
        userArray.forEach((element) {
          UserB newUser = UserB(
              email: element['email'],
              userName: element['userName'],
              photoURL: element['photoURL']);
          newUsers.add(newUser);
        });
        setState(() {
          currentUsers = newUsers;
        });
      }
    });
    socket.on('coordinates', (data) {
      var model = TransferModel.fromJson(data);
      var offset = Offset(model.dx, model.dy);
      var paint = Paint()
        ..strokeWidth = model.StrokeWidth
        ..color = Color(model.colorCode);
      var drawmodel = DrawModel(offset: offset, paint: paint);
      pointsList.add(drawmodel);
      pointsStream.add(pointsList);
    });
    socket.on('completed', (data) {
      if (data == true) {
        pointsList.add(null);
        pointsStream.add(pointsList);
      }
    });

    socket.on('newUser', (data) {
      var user = UserB(
          email: data['email'],
          userName: data['userName'],
          photoURL: data['photoURL']);
      setState(() {
        currentUsers.add(user);
      });
    });

    print(socket.connected);
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    pointsStream.close();
    super.dispose();
  }

  void emitCoordinates(TransferModel model) {
    socket.emit('coordinates', model.toJson());
  }

  getColorList() {
    List<Widget> listWidget = List();
    for (Color color in colors) {
      listWidget.add(colorCircle(color));
    }
    Widget colorPicker = GestureDetector(
      onTap: () {
        showDialog(
          builder: (context) => AlertDialog(
            title: const Text('Pick a color!'),
            content: SingleChildScrollView(
              child: ColorPicker(
                pickerColor: pickerColor,
                onColorChanged: (color) {
                  pickerColor = color;
                },
                pickerAreaHeightPercent: 0.8,
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: const Text('Save'),
                onPressed: () {
                  setState(() => selectedColor = pickerColor);
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
          context: context,
        );
      },
      child: ClipOval(
        child: Container(
          padding: EdgeInsets.only(bottom: 20),
          height: 36,
          width: 36,
          decoration: BoxDecoration(
              gradient: LinearGradient(
            colors: [Colors.red, Colors.green, Colors.blue],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          )),
        ),
      ),
    );
    listWidget.add(colorPicker);
    return listWidget;
  }

  Widget colorCircle(Color color) {
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedColor = color;
        });
      },
      child: ClipOval(
        child: Container(
          padding: const EdgeInsets.only(bottom: 16.0),
          height: 36,
          width: 36,
          color: color,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      key: key,
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15.0),
        child: Container(
            padding: const EdgeInsets.only(left: 8.0, right: 8.0),
            decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(50.0),
                color: Colors.greenAccent),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                          icon: Icon(Icons.album),
                          onPressed: () {
                            setState(() {
                              if (selectedMode == SelectedMode.StrokeWidth)
                                showBottomList = !showBottomList;
                              selectedMode = SelectedMode.StrokeWidth;
                            });
                          }),
                      IconButton(
                          icon: Icon(Icons.opacity),
                          onPressed: () {
                            setState(() {
                              if (selectedMode == SelectedMode.Opacity)
                                showBottomList = !showBottomList;
                              selectedMode = SelectedMode.Opacity;
                            });
                          }),
                      IconButton(
                          icon: Icon(Icons.color_lens),
                          onPressed: () {
                            setState(() {
                              if (selectedMode == SelectedMode.Color)
                                showBottomList = !showBottomList;
                              selectedMode = SelectedMode.Color;
                            });
                          }),
                      Flexible(
                        child: Container(
                          decoration: BoxDecoration(
                              color: getContigousStatus(),
                              borderRadius: BorderRadius.circular(30)),
                          child: IconButton(
                              onPressed: () {
                                setState(() {
                                  pointsList.add(null);
                                  setState(() {
                                    contiguous = !contiguous;
                                  });
                                  socket.emit('completed', contiguous);
                                });
                              },
                              icon: Icon(Icons.timeline)),
                        ),
                      ),
                      IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              // showBottomList = false;
                              // pointsList.clear();
                              Navigator.pop(context);
                            });
                          }),
                    ],
                  ),
                  Visibility(
                    child: (selectedMode == SelectedMode.Color)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: getColorList(),
                          )
                        : Slider(
                            value: (selectedMode == SelectedMode.StrokeWidth)
                                ? strokeWidth
                                : opacity,
                            max: (selectedMode == SelectedMode.StrokeWidth)
                                ? 50.0
                                : 1.0,
                            min: 0.0,
                            onChanged: (val) {
                              setState(() {
                                if (selectedMode == SelectedMode.StrokeWidth)
                                  strokeWidth = val;
                                else
                                  opacity = val;
                              });
                            }),
                    visible: showBottomList,
                  ),
                ],
              ),
            )),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            GestureDetector(
              onPanStart: (details) {
                Paint paint = Paint()
                  ..strokeCap = StrokeCap.round
                  ..color = selectedColor.withOpacity(opacity)
                  ..isAntiAlias = true
                  ..strokeWidth = strokeWidth;
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                DrawModel model = DrawModel(
                    offset: renderBox.globalToLocal(details.globalPosition),
                    paint: paint);
                // emitCoordinates(model);
                pointsList.add(model);
                pointsStream.add(pointsList);

                emitCoordinates(TransferModel(
                    dx: details.globalPosition.dx,
                    dy: details.globalPosition.dy,
                    colorCode: selectedColor.withOpacity(opacity).hashCode,
                    StrokeWidth: strokeWidth));
              },
              onPanUpdate: (details) {
                Paint paint = Paint()
                  ..strokeCap = StrokeCap.round
                  ..color = selectedColor.withOpacity(opacity)
                  ..isAntiAlias = true
                  ..strokeWidth = strokeWidth;
                RenderBox renderBox = context.findRenderObject() as RenderBox;
                DrawModel model = DrawModel(
                    offset: renderBox.globalToLocal(details.globalPosition),
                    paint: paint);
                // emitCoordinates(model);

                pointsList.add(model);
                pointsStream.add(pointsList);
                emitCoordinates(TransferModel(
                    dx: details.globalPosition.dx,
                    dy: details.globalPosition.dy,
                    colorCode: selectedColor.withOpacity(opacity).hashCode,
                    StrokeWidth: strokeWidth));
              },
              onPanEnd: (details) {
                if (contiguous) {
                  pointsList.add(null);
                  pointsStream.add(pointsList);
                }
                socket.emit('completed', contiguous);
              },
              child: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                child: StreamBuilder<List<DrawModel>>(
                    stream: pointsStream,
                    builder: (context, snapshot) {
                      return CustomPaint(
                        painter:
                            DrawingPainter(pointsList: snapshot.data ?? []),
                      );
                    }),
              ),
            ),
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                      height: 70.h,
                      width: 400.w,
                      decoration: BoxDecoration(
                        color: Colors.greenAccent,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: ListView.builder(
                            shrinkWrap: true,
                            scrollDirection: Axis.horizontal,
                            itemCount: currentUsers.length,
                            itemBuilder: (_, index) {
                              return Container(
                                height: 40.h,
                                width: 40.w,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20.r)),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(20.r),
                                  child: Image(
                                    image: NetworkImage(
                                        currentUsers.elementAt(index).photoURL),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              );
                            }),
                      )),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
