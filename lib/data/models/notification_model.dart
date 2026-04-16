// lib/data/models/notification_model.dart
import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';

part 'notification_model.g.dart';

@JsonSerializable(includeIfNull: false)
class NotificationModel {
  @JsonKey(name: AppDatabase.colId)
  final String id;

  @JsonKey(name: AppDatabase.colUserId)
  final String userId;

  @JsonKey(name: AppDatabase.colTitle)
  final String title;

  @JsonKey(name: AppDatabase.colContent)
  final String content;

  @JsonKey(name: AppDatabase.colIsRead)
  bool isRead;

  @JsonKey(name: AppDatabase.colCreatedAt)
  final DateTime createdAt;

  @JsonKey(name: AppDatabase.colType)
  final String? type; // LEAVE_REQUEST, LEAVE_RESULT...

  @JsonKey(name: AppDatabase.colReferenceId)
  final String? referenceId;

  NotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.content,
    this.isRead = false,
    required this.createdAt,
    this.type,
    this.referenceId,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) => 
      _$NotificationModelFromJson(json);

  Map<String, dynamic> toJson() => _$NotificationModelToJson(this);
}