// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_comment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityCommentModel _$ActivityCommentModelFromJson(
  Map<String, dynamic> json,
) => ActivityCommentModel(
  id: json['id'] as String,
  activityLogId: json['activity_log_id'] as String,
  userId: json['user_id'] as String,
  content: json['content'] as String,
  createdAt: DateHelper.parseUtc(json['created_at']),
  userName: json['userName'] as String?,
  userRole: json['userRole'] as String?,
);

Map<String, dynamic> _$ActivityCommentModelToJson(
  ActivityCommentModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'activity_log_id': instance.activityLogId,
  'user_id': instance.userId,
  'content': instance.content,
  'created_at': instance.createdAt.toIso8601String(),
};
