// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LeaveRequestModel _$LeaveRequestModelFromJson(Map<String, dynamic> json) =>
    LeaveRequestModel(
      id: json['id'] as String?,
      studentId: json['student_id'] as String,
      parentId: json['parent_id'] as String,
      approvedBy: json['approved_by'] as String?,
      reason: json['reason'] as String,
      status: json['status'] as String,
      startDate: json['start_date'] as String,
      endDate: json['end_date'] as String,
      createdAt: DateHelper.parseUtcNullable(json['created_at']),
      approvedAt: DateHelper.parseUtcNullable(json['approved_at']),
      student: json['students'] == null
          ? null
          : StudentModel.fromJson(json['students'] as Map<String, dynamic>),
      cancelReason: json['cancel_reason'] as String?,
      images: json['images'] == null
          ? const []
          : LeaveRequestModel._imagesFromJson(json['images']),
    );

Map<String, dynamic> _$LeaveRequestModelToJson(LeaveRequestModel instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'student_id': instance.studentId,
      'parent_id': instance.parentId,
      'approved_by': ?instance.approvedBy,
      'reason': instance.reason,
      'status': instance.status,
      'start_date': instance.startDate,
      'end_date': instance.endDate,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'approved_at': ?instance.approvedAt?.toIso8601String(),
      'cancel_reason': ?instance.cancelReason,
      'images': instance.images,
    };
