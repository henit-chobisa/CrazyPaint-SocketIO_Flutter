import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:frontend/LandingPage.dart';
import 'package:lottie/lottie.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  final FirebaseAuth auth = FirebaseAuth.instance;
  final GoogleSignIn googleSignIn = GoogleSignIn();
  AnimationController _controller;
  String alert = "Continue wuth google";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  Future<void> saveUserInfo() async {
    var body = {
      "email": auth.currentUser.email,
      "photoURL": auth.currentUser.photoURL,
      "userName": auth.currentUser.displayName
    };
    var headers = {"Content-Type": "application/json"};
    var response = await http.post(
        Uri.parse("https://crazypaint.herokuapp.com/login"),
        body: jsonEncode(body),
        headers: headers);
    setState(() {
      alert = "Continue with google";
    });
    if (response.statusCode == 200) {
      SharedPreferences.setMockInitialValues({});
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("email", auth.currentUser.email);
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (_) => LandingPage()));
    }
  }

  void requestLogin() async {
    setState(() {
      alert = "Loading...";
    });
    final user = await GoogleSignIn().signIn();
    if (user != null) {
      final googleAuth = await user.authentication;
      final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);
      await FirebaseAuth.instance
          .signInWithCredential(credential)
          .whenComplete(() => saveUserInfo());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.redAccent,
      body: SafeArea(
        child: Stack(
          children: [
            // Container(
            //   height: MediaQuery.of(context).size.height,
            //   child: Lottie.asset('Lottie/background.json',
            //       fit: BoxFit.fitHeight,
            //       controller: _controller, onLoaded: (composition) {
            //     _controller.duration = Duration(seconds: 5);
            //     _controller.forward();
            //   }),
            // ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SizedBox(
                  height: 100.h,
                ),
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
                    style: TextStyle(color: Colors.white, fontSize: 14.sp),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                ),
                Lottie.asset('Lottie/cube.json'),
                Spacer(),
                GestureDetector(
                  onTap: () {
                    requestLogin();
                  },
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Container(
                      height: 60.h,
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20.r)),
                      child: Center(
                        child: Text(
                          alert,
                          style: TextStyle(
                              color: Colors.black,
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 30.h,
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
