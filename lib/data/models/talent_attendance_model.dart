import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';

part 'talent_attendance_model.g.dart';

@JsonSerializable()
class TalentAttendanceModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colStudentId)
  final String studentId;

  @JsonKey(name: AppDatabase.colTalentClassId)
  final String talentClassId;

  @JsonKey(name: AppDatabase.colDate)
  final DateTime date;

  @JsonKey(name: AppDatabase.colStatus)
  final String status;

  @JsonKey(name: AppDatabase.colNote)
  final String? note;

  @JsonKey(name: AppDatabase.colCreatedAt)
  final DateTime? createdAt;

  TalentAttendanceModel({
    this.id,
    required this.studentId,
    required this.talentClassId,
    required this.date,
    this.status = AppDatabase.statusPresent,
    this.note,
    this.createdAt,
  });

  factory TalentAttendanceModel.fromJson(Map<String, dynamic> json) => _$TalentAttendanceModelFromJson(json);
  Map<String, dynamic> toJson() => _$TalentAttendanceModelToJson(this);
}
