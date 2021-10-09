import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
    var response = await http.post(Uri.parse("http://127.0.0.1:2000/login"),
        body: jsonEncode(body), headers: headers);
    if (response.statusCode == 200) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("email", auth.currentUser.email).then((value) => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => )));
    }
  }

  void requestLogin() async {
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
                          "Continue with google",
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

class customTextFeild extends StatelessWidget {
  customTextFeild(
      {this.hintText, this.obsText, this.controller, this.inputType});

  String hintText;
  bool obsText;
  TextInputType inputType;
  TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: Container(
        height: 60.h,
        width: double.maxFinite,
        decoration: BoxDecoration(
            color: Colors.grey.shade800,
            borderRadius: BorderRadius.circular(20.r)),
        child: Padding(
          padding:
              EdgeInsets.only(left: 16.w, right: 16.w, top: 5.h, bottom: 5.h),
          child: TextField(
            obscureText: obsText,
            controller: controller,
            keyboardType: inputType,
            cursorColor: Colors.white,
            textAlign: TextAlign.center,
            decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: TextStyle(color: Colors.grey.shade500)),
            style: TextStyle(color: Colors.white, fontSize: 15.sp),
          ),
        ),
      ),
    );
  }
}
