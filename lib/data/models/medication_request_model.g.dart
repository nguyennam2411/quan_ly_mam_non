// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'medication_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

MedicationRequestModel _$MedicationRequestModelFromJson(
  Map<String, dynamic> json,
) => MedicationRequestModel(
  id: json['id'] as String?,
  studentId: json['student_id'] as String,
  parentId: json['parent_id'] as String,
  approvedBy: json['approved_by'] as String?,
  medicineName: json['medicine_name'] as String,
  dosage: json['dosage'] as String,
  time: json['time'] as String,
  note: json['note'] as String?,
  date: json['date'] as String,
  prescriptionImage: json['prescription_image'] as String?,
  status: json['status'] as String,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  approvedAt: json['approved_at'] == null
      ? null
      : DateTime.parse(json['approved_at'] as String),
  student: json['students'] == null
      ? null
      : StudentModel.fromJson(json['students'] as Map<String, dynamic>),
);

Map<String, dynamic> _$MedicationRequestModelToJson(
  MedicationRequestModel instance,
) => <String, dynamic>{
  'id': ?instance.id,
  'student_id': instance.studentId,
  'parent_id': instance.parentId,
  'approved_by': ?instance.approvedBy,
  'medicine_name': instance.medicineName,
  'dosage': instance.dosage,
  'time': instance.time,
  'note': ?instance.note,
  'date': instance.date,
  'prescription_image': ?instance.prescriptionImage,
  'status': instance.status,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'approved_at': ?instance.approvedAt?.toIso8601String(),
};
