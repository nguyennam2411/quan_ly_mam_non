// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_log_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityLogModel _$ActivityLogModelFromJson(Map<String, dynamic> json) =>
    ActivityLogModel(
      id: json['id'] as String?,
      classroomId: json['classroom_id'] as String,
      teacherId: json['teacher_id'] as String,
      studentId: json['student_id'] as String?,
      content: json['content'] as String,
      createdAt: DateHelper.parseUtcNullable(json['created_at']),
      images: (json['activity_images'] as List<dynamic>?)
          ?.map((e) => ActivityImageModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      student: json['students'] == null
          ? null
          : StudentModel.fromJson(json['students'] as Map<String, dynamic>),
      likeCount: (json['likeCount'] as num?)?.toInt() ?? 0,
      commentCount: (json['commentCount'] as num?)?.toInt() ?? 0,
      isLiked: json['isLiked'] as bool? ?? false,
      comments: (json['comments'] as List<dynamic>?)
          ?.map((e) => ActivityCommentModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ActivityLogModelToJson(ActivityLogModel instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'classroom_id': instance.classroomId,
      'teacher_id': instance.teacherId,
      'student_id': ?instance.studentId,
      'content': instance.content,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'likeCount': instance.likeCount,
      'commentCount': instance.commentCount,
      'isLiked': instance.isLiked,
    };
