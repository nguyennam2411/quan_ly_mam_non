// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_guardian_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentGuardianModel _$StudentGuardianModelFromJson(
  Map<String, dynamic> json,
) => StudentGuardianModel(
  id: json['id'] as String,
  studentId: json['student_id'] as String,
  name: json['name'] as String,
  phone: json['phone'] as String,
  relationship: json['relationship'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$StudentGuardianModelToJson(
  StudentGuardianModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'student_id': instance.studentId,
  'name': instance.name,
  'phone': instance.phone,
  'relationship': instance.relationship,
  'created_at': instance.createdAt?.toIso8601String(),
  'updated_at': instance.updatedAt?.toIso8601String(),
};
