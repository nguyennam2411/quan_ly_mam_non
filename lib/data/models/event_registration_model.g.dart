// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_registration_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EventRegistrationModel _$EventRegistrationModelFromJson(
  Map<String, dynamic> json,
) => EventRegistrationModel(
  id: json['id'] as String?,
  eventId: json['event_id'] as String,
  studentId: json['student_id'] as String,
  status: json['status'] as String? ?? AppDatabase.statusRegistered,
  note: json['note'] as String?,
  registeredAt: json['registered_at'] == null
      ? null
      : DateTime.parse(json['registered_at'] as String),
);

Map<String, dynamic> _$EventRegistrationModelToJson(
  EventRegistrationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'event_id': instance.eventId,
  'student_id': instance.studentId,
  'status': instance.status,
  'note': instance.note,
  'registered_at': instance.registeredAt?.toIso8601String(),
};
