import 'package:json_annotation/json_annotation.dart';
import 'package:flutter/material.dart';
import '../../core/values/app_database.dart';

part 'schedule_model.g.dart';

@JsonSerializable()
class ScheduleModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colClassroomId)
  final String classroomId;

  @JsonKey(name: AppDatabase.colDayOfWeek)
  final int dayOfWeek;

  @JsonKey(name: AppDatabase.colStartTime)
  final String startTime; // Định dạng "HH:mm:ss"

  @JsonKey(name: AppDatabase.colEndTime)
  final String endTime;

  @JsonKey(name: AppDatabase.colActivityName)
  final String activityName;

  @JsonKey(name: AppDatabase.colIsLessonSlot)
  final bool isLessonSlot;

  @JsonKey(name: AppDatabase.colNote)
  final String? note;

  ScheduleModel({
    this.id,
    required this.classroomId,
    required this.dayOfWeek,
    required this.startTime,
    required this.endTime,
    required this.activityName,
    this.isLessonSlot = false,
    this.note,
  });

  // Chuyển đổi String time sang TimeOfDay để hiển thị UI
  TimeOfDay get startToTimeOfDay => _parseTime(startTime);
  TimeOfDay get endToTimeOfDay => _parseTime(endTime);

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  factory ScheduleModel.fromJson(Map<String, dynamic> json) => _$ScheduleModelFromJson(json);
  Map<String, dynamic> toJson() => _$ScheduleModelToJson(this);
}