import 'dart:async';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/material.dart';
import 'package:frontend/LandingPage.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'LoginPage.dart';

class LogoPage extends StatefulWidget {
  const LogoPage({Key key}) : super(key: key);

  @override
  _LogoPageState createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> with TickerProviderStateMixin {
  AnimationController _controller;
  bool LoggedIn = false;

  void check() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // var mail = prefs.get('email');
    // print(mail);
    // if (mail != null) {
    //   setState(() {
    //     LoggedIn = true;
    //   });
    // } else {
    //   print("email doesn't exist");
    // }
    FirebaseAuth auth = FirebaseAuth.instance;
    var currentUser = auth.currentUser;
    if (currentUser == null) {
      print("No user");
    } else {
      print("user exist");
      setState(() {
        LoggedIn = true;
      });
    }
  }

  @override
  void initState() {
    check();
    super.initState();
    Timer(Duration(seconds: 5), () {
      print(LoggedIn);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (_) => LoggedIn == true ? LandingPage() : LoginPage()));
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
                      fontSize: 50.sp,
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
