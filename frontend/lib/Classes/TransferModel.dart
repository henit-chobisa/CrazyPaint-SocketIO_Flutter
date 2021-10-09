import 'dart:ui';
import 'package:json_annotation/json_annotation.dart';

part 'TransferModel.g.dart';

@JsonSerializable()
class TransferModel {
  TransferModel({this.dx, this.dy, this.StrokeWidth, this.colorCode});

  factory TransferModel.fromJson(Map<String, dynamic> data) =>
      _$TransferModelFromJson(data);
  Map<String, dynamic> toJson() => _$TransferModelToJson(this);

  double dx;
  double dy;
  double StrokeWidth;
  int colorCode;
}
