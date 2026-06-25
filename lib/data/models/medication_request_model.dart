import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';
import 'student_model.dart';

part 'medication_request_model.g.dart';

@JsonSerializable(includeIfNull: false)
class MedicationRequestModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colStudentId)
  final String studentId;

  @JsonKey(name: AppDatabase.colParentId)
  final String parentId;

  @JsonKey(name: AppDatabase.colApprovedBy)
  final String? approvedBy;

  @JsonKey(name: AppDatabase.colMedicineName)
  final String medicineName;

  @JsonKey(name: AppDatabase.colDosage)
  final String dosage;

  @JsonKey(name: AppDatabase.colTime)
  final String time;

  @JsonKey(name: AppDatabase.colNote)
  final String? note;

  @JsonKey(name: AppDatabase.colDate)
  final String date; 

  @JsonKey(name: AppDatabase.colPrescriptionImage)
  final String? prescriptionImage;

  @JsonKey(name: AppDatabase.colStatus)
  final String status; // PENDING, APPROVED, REJECTED, CANCELLED

  @JsonKey(name: AppDatabase.colCreatedAt)
  final DateTime? createdAt;

  @JsonKey(name: AppDatabase.colApprovedAt)
  final DateTime? approvedAt;
  
  // Trường bổ sung để hiển thị thông tin học sinh (không lưu xuống DB)
  @JsonKey(name: 'students', includeToJson: false)
  final StudentModel? student;

  MedicationRequestModel({
    this.id,
    required this.studentId,
    required this.parentId,
    this.approvedBy,
    required this.medicineName,
    required this.dosage,
    required this.time,
    this.note,
    required this.date,
    this.prescriptionImage,
    required this.status,
    this.createdAt,
    this.approvedAt,
    this.student,
  });

  // Chuyển từ JSON (Supabase) sang Model
  factory MedicationRequestModel.fromJson(Map<String, dynamic> json) => 
      _$MedicationRequestModelFromJson(json);

  // Chuyển từ Model sang JSON để đẩy lên Supabase
  Map<String, dynamic> toJson() => _$MedicationRequestModelToJson(this);
}
