// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talent_attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TalentAttendanceModel _$TalentAttendanceModelFromJson(
  Map<String, dynamic> json,
) => TalentAttendanceModel(
  id: json['id'] as String?,
  studentId: json['student_id'] as String,
  talentClassId: json['talent_class_id'] as String,
  date: DateTime.parse(json['date'] as String),
  status: json['status'] as String? ?? AppDatabase.statusPresent,
  note: json['note'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$TalentAttendanceModelToJson(
  TalentAttendanceModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'student_id': instance.studentId,
  'talent_class_id': instance.talentClassId,
  'date': instance.date.toIso8601String(),
  'status': instance.status,
  'note': instance.note,
  'created_at': instance.createdAt?.toIso8601String(),
};
