// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'qr_token_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QrTokenModel _$QrTokenModelFromJson(Map<String, dynamic> json) => QrTokenModel(
  id: json['id'] as String?,
  studentId: json['student_id'] as String,
  code: json['code'] as String,
);

Map<String, dynamic> _$QrTokenModelToJson(QrTokenModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'code': instance.code,
    };
