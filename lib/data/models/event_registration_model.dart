import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';

part 'event_registration_model.g.dart';

@JsonSerializable()
class EventRegistrationModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colEventId)
  final String eventId;

  @JsonKey(name: AppDatabase.colStudentId)
  final String studentId;

  @JsonKey(name: AppDatabase.colStatus)
  final String status;

  @JsonKey(name: AppDatabase.colNote)
  final String? note;

  @JsonKey(name: AppDatabase.colRegisteredAt)
  final DateTime? registeredAt;

  EventRegistrationModel({
    this.id,
    required this.eventId,
    required this.studentId,
    this.status = AppDatabase.statusRegistered,
    this.note,
    this.registeredAt,
  });

  factory EventRegistrationModel.fromJson(Map<String, dynamic> json) => _$EventRegistrationModelFromJson(json);
  Map<String, dynamic> toJson() => _$EventRegistrationModelToJson(this);
}
