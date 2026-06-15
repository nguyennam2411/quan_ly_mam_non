// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventModel _$EventModelFromJson(Map<String, dynamic> json) => EventModel(
  id: json['id'] as String?,
  title: json['title'] as String,
  description: json['description'] as String?,
  startDate: DateTime.parse(json['start_date'] as String),
  endDate: DateTime.parse(json['end_date'] as String),
  deadlineDate: DateTime.parse(json['deadline_date'] as String),
  location: json['location'] as String,
  fee: (json['fee'] as num?)?.toInt() ?? 0,
  imageUrl: json['image_url'] as String?,
  documentUrl: json['document_url'] as String?,
  status: json['status'] as String? ?? AppDatabase.statusUpcoming,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$EventModelToJson(EventModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'description': instance.description,
      'start_date': instance.startDate.toIso8601String(),
      'end_date': instance.endDate.toIso8601String(),
      'deadline_date': instance.deadlineDate.toIso8601String(),
      'location': instance.location,
      'fee': instance.fee,
      'image_url': instance.imageUrl,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
      'document_url': instance.documentUrl,
    };
