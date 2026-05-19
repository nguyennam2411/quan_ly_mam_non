// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lesson_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LessonModel _$LessonModelFromJson(Map<String, dynamic> json) => LessonModel(
  id: json['id'] as String?,
  classroomId: json['classroom_id'] as String,
  scheduleId: json['schedule_id'] as String?,
  title: json['title'] as String,
  objectives: json['objectives'] as String?,
  content: json['content'] as String?,
  date: DateHelper.parseUtc(json['date']),
  images:
      (json['images'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const [],
  youtubeUrl: json['youtube_url'] as String?,
  attachmentUrl: json['attachment_url'] as String?,
  status: json['status'] as String? ?? AppDatabase.statusDraft,
  createdAt: DateHelper.parseUtc(json['created_at']),
);

Map<String, dynamic> _$LessonModelToJson(LessonModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'classroom_id': instance.classroomId,
      'schedule_id': instance.scheduleId,
      'title': instance.title,
      'objectives': instance.objectives,
      'content': instance.content,
      'date': instance.date.toIso8601String(),
      'images': instance.images,
      'youtube_url': instance.youtubeUrl,
      'attachment_url': instance.attachmentUrl,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
    };
