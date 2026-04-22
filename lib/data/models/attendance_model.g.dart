// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'attendance_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttendanceModel _$AttendanceModelFromJson(Map<String, dynamic> json) =>
    AttendanceModel(
      id: json['id'] as String?,
      studentId: json['student_id'] as String,
      date: json['date'] as String,
      status: json['status'] as String,
      note: json['note'] as String?,
      method: json['method'] as String?,
      checkinTime: json['checkin_time'] as String?,
      classroomId: json['classroom_id'] as String?,
      teacherId: json['teacher_id'] as String?,
    );

Map<String, dynamic> _$AttendanceModelToJson(AttendanceModel instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'student_id': instance.studentId,
      'date': instance.date,
      'status': instance.status,
      'note': ?instance.note,
      'method': ?instance.method,
      'checkin_time': ?instance.checkinTime,
      'classroom_id': ?instance.classroomId,
      'teacher_id': ?instance.teacherId,
    };
