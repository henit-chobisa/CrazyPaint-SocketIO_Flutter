import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        width: 360.w,
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
