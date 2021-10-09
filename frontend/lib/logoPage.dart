import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import 'LoginPage.dart';

class LogoPage extends StatefulWidget {
  const LogoPage({Key key}) : super(key: key);

  @override
  _LogoPageState createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> with TickerProviderStateMixin {
  AnimationController _controller;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LoginPage()));
    });
    _controller = AnimationController(vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            height: MediaQuery.of(context).size.height,
            child: Lottie.asset('Lottie/background.json',
                fit: BoxFit.fitHeight,
                controller: _controller, onLoaded: (composition) {
              _controller.duration = Duration(seconds: 5);
              _controller.forward();
            }),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Text(
                  "Crazy Paint",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 50,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Center(
                child: Text(
                  'Developed and Designed by Henit Chobisa',
                  style: TextStyle(color: Colors.white),
                ),
              )
            ],
          )
        ],
      ),
    );
  }
}
