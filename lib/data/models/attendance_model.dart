import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';
part 'attendance_model.g.dart';

@JsonSerializable(includeIfNull: false)
class AttendanceModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;
  
  @JsonKey(name: AppDatabase.colStudentId)
  final String studentId;
  
  @JsonKey(name: AppDatabase.colDate)
  final String date; // Lưu dạng String YYYY-MM-DD để dễ so khớp
  
  @JsonKey(name: AppDatabase.colStatus)
  final String status;
  
  @JsonKey(name: AppDatabase.colNote)
  final String? note;
  
  @JsonKey(name: AppDatabase.colMethod)
  final String? method;

  @JsonKey(name: AppDatabase.colCheckinTime)
  final String? checkinTime;

  @JsonKey(name: AppDatabase.colClassroomId)
  final String? classroomId;

  @JsonKey(name: AppDatabase.colTeacherId)
  final String? teacherId;

  AttendanceModel({
    this.id, 
    required this.studentId, 
    required this.date, 
    required this.status, 
    this.note, 
    this.method,
    this.checkinTime,
    this.classroomId,
    this.teacherId,
  });

  factory AttendanceModel.fromJson(Map<String, dynamic> json) => _$AttendanceModelFromJson(json);
  Map<String, dynamic> toJson() => _$AttendanceModelToJson(this);
}