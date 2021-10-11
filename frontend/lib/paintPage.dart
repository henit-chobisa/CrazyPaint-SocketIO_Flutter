import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:frontend/Classes/TransferModel.dart';
import 'package:rxdart/rxdart.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'Classes/DrawingModel.dart';
import 'Classes/DrawingPainter.dart';
import 'dart:ui';
import 'dart:async';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:permission_handler/permission_handler.dart';
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
  var APP_ID = '08478a3f085f4cbdb8c246d288dfb81b';
  var Token =
      '00608478a3f085f4cbdb8c246d288dfb81bIACOHEUIuvXvmNU3YXfoCIDkm7qm2aumNdhqRYmwzgj/VWHTcgkAAAAAEACTqYr9QgRlYQEAAQBABGVh';

  bool micOn = true;
  bool _joined = false;
  int _remoteUid = 0;
  bool _switch = false;
  RtcEngine engine;
  bool MicVisible = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    ConnectIO();
  }

  void turnOffMic() async {
    await engine.muteLocalAudioStream(true);
    setState(() {
      micOn = false;
    });
  }

  void turnOnMic() async {
    await engine.muteLocalAudioStream(false);
    setState(() {
      micOn = true;
    });
  }

  Future<void> initPlatformState() async {
    await [Permission.microphone].request();
    // Create RTC client instance
    RtcEngineContext context = RtcEngineContext(APP_ID);
    engine = await RtcEngine.createWithContext(context);
    // Define event handling logic
    engine.setEventHandler(RtcEngineEventHandler(
        joinChannelSuccess: (String channel, int uid, int elapsed) {
      print('joinChannelSuccess ${channel} ${uid}');
      setState(() {
        _joined = true;
      });
    }, userJoined: (int uid, int elapsed) {
      print('userJoined ${uid}');
      setState(() {
        _remoteUid = uid;
      });
    }, userOffline: (int uid, UserOfflineReason reason) {
      print('userOffline ${uid}');
      setState(() {
        _remoteUid = 0;
      });
    }, tokenPrivilegeWillExpire: (value) {
      print(value);
      print('token will expire');
    }));

    engine.enableLocalAudio(true);
    // Join channel with channel name as 123
    await engine.joinChannel(Token, widget.roomID, null, 0);
    setState(() {
      MicVisible = true;
    });
  }

  Color getContigousStatus() {
    if (contiguous) {
      return Colors.transparent;
    } else {
      return Colors.white;
    }
  }

  void ConnectIO() async {
    socket = io.io(
        "https://crazypaint.herokuapp.com/?roomID=${widget.roomID}",
        <String, dynamic>{
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
      if (data != null) {
        List<UserB> newUsers = [];
        var userArray = data['users'] as List<dynamic>;
        userArray.forEach((element) {
          UserB newUser = UserB(
              email: element['email'],
              userName: element['username'],
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

    print(socket.connected);
  }

  @override
  void dispose() {
    engine.leaveChannel();
    engine.destroy();
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(
                            Icons.arrow_back_ios,
                            color: Colors.black,
                          )),
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
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                    backgroundColor: Colors.greenAccent,
                                    title: Text(
                                      "Room Information",
                                      style: TextStyle(
                                          color: Colors.black, fontSize: 12.sp),
                                    ),
                                    content: SingleChildScrollView(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "Current Room ID",
                                            style: TextStyle(
                                                fontSize: 14.sp,
                                                color: Colors.black),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Center(
                                            child: Text(
                                              widget.roomID,
                                              style: TextStyle(
                                                  fontSize: 12.sp,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Text("User Information",
                                              style: TextStyle(
                                                  fontSize: 14.sp,
                                                  color: Colors.black)),
                                          SizedBox(
                                            height: 10.h,
                                          ),
                                          Container(
                                            height: 300.h,
                                            width: double.maxFinite,
                                            child: ListView.builder(
                                                scrollDirection: Axis.vertical,
                                                shrinkWrap: true,
                                                itemCount: currentUsers.length,
                                                itemBuilder: (_, index) {
                                                  print(currentUsers
                                                      .elementAt(0)
                                                      .userName);
                                                  return AttendeeBox(
                                                    name: currentUsers
                                                        .elementAt(index)
                                                        .userName,
                                                    email: currentUsers
                                                        .elementAt(index)
                                                        .email,
                                                    photoURL: currentUsers
                                                        .elementAt(index)
                                                        .photoURL,
                                                  );
                                                }),
                                          )
                                        ],
                                      ),
                                    ),
                                  ));
                        },
                        icon: Icon(Icons.info_outline),
                        color: Colors.black,
                      ),
                      IconButton(
                          icon: Icon(Icons.clear),
                          onPressed: () {
                            setState(() {
                              showBottomList = false;
                              pointsList.clear();
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
                  Padding(
                    padding: EdgeInsets.only(left: 16.w, top: 15.h),
                    child: Text(
                      "Users in Room",
                      style: TextStyle(fontSize: 12.sp),
                    ),
                  ),
                  Row(
                    children: [
                      Container(
                          height: 70.h,
                          width: 320.w,
                          decoration: BoxDecoration(
                            color: Colors.greenAccent,
                            borderRadius: BorderRadius.circular(40.r),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: currentUsers.length,
                                itemBuilder: (_, index) {
                                  return Padding(
                                    padding: EdgeInsets.only(right: 3.w),
                                    child: Container(
                                      height: 30.h,
                                      width: 30.w,
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(15.r)),
                                      child: ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(15.r),
                                        child: Image(
                                          image: NetworkImage(currentUsers
                                              .elementAt(index)
                                              .photoURL),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  );
                                }),
                          )),
                      Visibility(
                        visible: MicVisible,
                        child: GestureDetector(
                          onTap: () {
                            if (micOn) {
                              turnOffMic();
                            } else {
                              turnOnMic();
                            }
                          },
                          child: Icon(
                            micOn ? Icons.mic : Icons.mic_off,
                            color: Colors.black,
                            size: 40.sp,
                          ),
                        ),
                      )
                    ],
                  ),
                ],
              ),
            )),
      ),
      body: GestureDetector(
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
                  painter: DrawingPainter(pointsList: snapshot.data ?? []),
                );
              }),
        ),
      ),
    );
  }
}

class AttendeeBox extends StatelessWidget {
  AttendeeBox({this.name, this.email, this.photoURL});

  final String name;
  final String photoURL;
  final String email;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(3.0),
      child: Container(
        width: double.maxFinite,
        height: 50.h,
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(20.r)),
        child: Row(
          children: [
            ClipRRect(
                borderRadius: BorderRadius.circular(20.r),
                child: Image(
                  image: NetworkImage(photoURL),
                  height: 40.h,
                  width: 40.h,
                )),
            SizedBox(
              width: 10.w,
            ),
            Padding(
              padding: EdgeInsets.all(7.sp),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                        fontSize: 13.sp),
                  ),
                  Text(
                    email,
                    style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.bold,
                        fontSize: 10.sp),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
