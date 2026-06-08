import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';

part 'student_guardian_model.g.dart';

@JsonSerializable()
class StudentGuardianModel {
  @JsonKey(name: AppDatabase.colId)
  final String id;

  @JsonKey(name: AppDatabase.colStudentId)
  final String studentId;

  @JsonKey(name: AppDatabase.colName)
  final String name;

  @JsonKey(name: AppDatabase.colPhone)
  final String phone;

  @JsonKey(name: AppDatabase.colRelationship)
  final String relationship;

  @JsonKey(name: AppDatabase.colCreatedAt)
  final DateTime? createdAt;

  @JsonKey(name: AppDatabase.colUpdatedAt)
  final DateTime? updatedAt;

  StudentGuardianModel({
    required this.id,
    required this.studentId,
    required this.name,
    required this.phone,
    required this.relationship,
    this.createdAt,
    this.updatedAt,
  });

  factory StudentGuardianModel.fromJson(Map<String, dynamic> json) =>
      _$StudentGuardianModelFromJson(json);

  Map<String, dynamic> toJson() => _$StudentGuardianModelToJson(this);
}
