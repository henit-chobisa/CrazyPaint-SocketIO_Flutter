import 'package:flutter/cupertino.dart';

class DrawModel {
  final Offset offset;
  final Paint paint;

  factory DrawModel.fromJson(Map<String, dynamic> data) =>
      _$DrawModelFromJson(data);
  Map<String, dynamic> toJson() => _$DrawModelToJson(this);

  DrawModel({this.offset, this.paint});
}
