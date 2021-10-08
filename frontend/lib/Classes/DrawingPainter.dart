import 'dart:ui';

import 'package:flutter/cupertino.dart';

import 'DrawingModel.dart';

class DrawingPainter extends CustomPainter {
  DrawingPainter({this.pointsList});

  final List<DrawModel> pointsList;

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < (pointsList.length); i++) {
      if (pointsList[i] != null && pointsList[i + 1] != null) {
        canvas.drawLine(pointsList[i].offset, pointsList[i + 1].offset,
            pointsList[i].paint);
      } else if (pointsList[i] != null && pointsList[i + 1] == null) {
        List<Offset> offsetList = [];
        offsetList.add(pointsList[i].offset);
        canvas.drawPoints(PointMode.points, offsetList, pointsList[i].paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
