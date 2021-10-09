// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'TransferModel.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TransferModel _$TransferModelFromJson(Map<String, dynamic> json) {
  return TransferModel(
    dx: (json['dx'] as num)?.toDouble(),
    dy: (json['dy'] as num)?.toDouble(),
    StrokeWidth: (json['StrokeWidth'] as num)?.toDouble(),
  )..colorCode = json['colorCode'] as int;
}

Map<String, dynamic> _$TransferModelToJson(TransferModel instance) =>
    <String, dynamic>{
      'dx': instance.dx,
      'dy': instance.dy,
      'StrokeWidth': instance.StrokeWidth,
      'colorCode': instance.colorCode,
    };
