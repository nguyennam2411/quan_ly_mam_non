// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_image_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ActivityImageModel _$ActivityImageModelFromJson(Map<String, dynamic> json) =>
    ActivityImageModel(
      id: json['id'] as String?,
      activityId: json['activity_id'] as String?,
      imageUrl: json['image_url'] as String,
    );

Map<String, dynamic> _$ActivityImageModelToJson(ActivityImageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'activity_id': instance.activityId,
      'image_url': instance.imageUrl,
    };
