import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';

part 'talent_enrollment_model.g.dart';

@JsonSerializable()
class TalentEnrollmentModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colStudentId)
  final String studentId;

  @JsonKey(name: AppDatabase.colTalentClassId)
  final String talentClassId;

  @JsonKey(name: AppDatabase.colStatus)
  final String status;

  @JsonKey(name: AppDatabase.colApprovedBy)
  final String? approvedBy;

  @JsonKey(name: AppDatabase.colRegisteredAt)
  final DateTime? registeredAt;

  TalentEnrollmentModel({
    this.id,
    required this.studentId,
    required this.talentClassId,
    this.status = AppDatabase.pending,
    this.approvedBy,
    this.registeredAt,
  });

  factory TalentEnrollmentModel.fromJson(Map<String, dynamic> json) => _$TalentEnrollmentModelFromJson(json);
  Map<String, dynamic> toJson() => _$TalentEnrollmentModelToJson(this);
}
