// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'student_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

StudentModel _$StudentModelFromJson(Map<String, dynamic> json) => StudentModel(
  id: json['id'] as String,
  name: json['name'] as String,
  classroomId: json['classroom_id'] as String?,
  parentId: json['parent_id'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  classroomName: json['classroomName'] as String?,
  gradeId: json['gradeId'] as String?,
  gradeName: json['gradeName'] as String?,
);

Map<String, dynamic> _$StudentModelToJson(StudentModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'classroom_id': instance.classroomId,
      'parent_id': instance.parentId,
      'avatar_url': instance.avatarUrl,
    };
