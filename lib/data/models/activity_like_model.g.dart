// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_like_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityLikeModel _$ActivityLikeModelFromJson(Map<String, dynamic> json) =>
    ActivityLikeModel(
      id: json['id'] as String,
      activityLogId: json['activity_log_id'] as String,
      userId: json['user_id'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ActivityLikeModelToJson(ActivityLikeModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activity_log_id': instance.activityLogId,
      'user_id': instance.userId,
      'created_at': instance.createdAt.toIso8601String(),
    };
