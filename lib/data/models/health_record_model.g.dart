// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'health_record_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

HealthRecordModel _$HealthRecordModelFromJson(Map<String, dynamic> json) =>
    HealthRecordModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      height: (json['height'] as num).toDouble(),
      weight: (json['weight'] as num).toDouble(),
      bmi: (json['bmi'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      teacherId: json['teacher_id'] as String?,
      note: json['note'] as String?,
    );

Map<String, dynamic> _$HealthRecordModelToJson(HealthRecordModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'student_id': instance.studentId,
      'height': instance.height,
      'weight': instance.weight,
      'bmi': instance.bmi,
      'date': instance.date.toIso8601String(),
      'teacher_id': instance.teacherId,
      'note': instance.note,
      'created_at': instance.createdAt.toIso8601String(),
    };
