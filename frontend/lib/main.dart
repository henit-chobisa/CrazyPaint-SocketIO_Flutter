import 'package:flutter/material.dart';
import 'package:frontend/logoPage.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(CrazyPaint());
}

class CrazyPaint extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(428, 926),
      builder: () => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Crazy_Paint',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: LogoPage(),
      ),
    );
  }
}
