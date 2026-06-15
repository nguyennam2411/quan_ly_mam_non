// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talent_enrollment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TalentEnrollmentModel _$TalentEnrollmentModelFromJson(
  Map<String, dynamic> json,
) => TalentEnrollmentModel(
  id: json['id'] as String?,
  studentId: json['student_id'] as String,
  talentClassId: json['talent_class_id'] as String,
  status: json['status'] as String? ?? AppDatabase.pending,
  approvedBy: json['approved_by'] as String?,
  registeredAt: json['registered_at'] == null
      ? null
      : DateTime.parse(json['registered_at'] as String),
);

Map<String, dynamic> _$TalentEnrollmentModelToJson(
  TalentEnrollmentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'student_id': instance.studentId,
  'talent_class_id': instance.talentClassId,
  'status': instance.status,
  'approved_by': instance.approvedBy,
  'registered_at': instance.registeredAt?.toIso8601String(),
};
