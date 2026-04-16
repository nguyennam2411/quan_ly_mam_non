import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';
import 'student_model.dart';

part 'leave_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class LeaveRequestModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colStudentId)
  final String studentId;

  @JsonKey(name: AppDatabase.colParentId)
  final String parentId;

  @JsonKey(name: AppDatabase.colApprovedBy)
  final String? approvedBy;

  @JsonKey(name: AppDatabase.colReason)
  final String reason;

  @JsonKey(name: AppDatabase.colStatus)
  final String status; // PENDING, APPROVED, REJECTED, CANCELLED

  @JsonKey(name: AppDatabase.colStartDate)
  final String startDate; 

  @JsonKey(name: AppDatabase.colEndDate)
  final String endDate; 

  @JsonKey(name: AppDatabase.colCreatedAt)
  final DateTime? createdAt;

  @JsonKey(name: AppDatabase.colApprovedAt)
  final DateTime? approvedAt;
  
  // Trường bổ sung để hiển thị thông tin học sinh (không lưu xuống DB)
  @JsonKey(name: 'students', includeToJson: false)
  final StudentModel? student;

  @JsonKey(name: AppDatabase.colCancelReason)
  final String? cancelReason;

  @JsonKey(name: AppDatabase.colEvidenceUrl)
  final String? evidenceUrl;

  LeaveRequestModel({
    this.id,
    required this.studentId,
    required this.parentId,
    this.approvedBy,
    required this.reason,
    required this.status,
    required this.startDate,
    required this.endDate,
    this.createdAt,
    this.approvedAt,
    this.student,
    this.cancelReason,
    this.evidenceUrl,
  });

  // Chuyển từ JSON (Supabase) sang Model
  factory LeaveRequestModel.fromJson(Map<String, dynamic> json) => 
      _$LeaveRequestModelFromJson(json);

  // Chuyển từ Model sang JSON để đẩy lên Supabase
  Map<String, dynamic> toJson() => _$LeaveRequestModelToJson(this);
}