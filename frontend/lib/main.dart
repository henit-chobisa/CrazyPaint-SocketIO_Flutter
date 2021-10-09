import 'package:flutter/material.dart';
import 'package:frontend/logoPage.dart';
import 'package:frontend/paintPage.dart';

void main() {
  runApp(CrazyPaint());
}

class CrazyPaint extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Crazy_Paint',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: LogoPage(),
    );
  }
}
