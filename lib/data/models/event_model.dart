import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';

part 'event_model.g.dart';

@JsonSerializable()
class EventModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colTitle)
  final String title;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: AppDatabase.colStartDate)
  final DateTime startDate;

  @JsonKey(name: AppDatabase.colEndDate)
  final DateTime endDate;

  @JsonKey(name: AppDatabase.colDeadlineDate)
  final DateTime deadlineDate;

  @JsonKey(name: AppDatabase.colLocation)
  final String location;

  @JsonKey(name: AppDatabase.colFee)
  final int fee;

  @JsonKey(name: AppDatabase.colImageUrl)
  final String? imageUrl;

  @JsonKey(name: AppDatabase.colStatus)
  final String status;

  @JsonKey(name: AppDatabase.colCreatedAt)
  final DateTime? createdAt;

  @JsonKey(name: 'document_url')
  final String? documentUrl;

  EventModel({
    this.id,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.deadlineDate,
    required this.location,
    this.fee = 0,
    this.imageUrl,
    this.documentUrl,
    this.status = AppDatabase.statusUpcoming,
    this.createdAt,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) => _$EventModelFromJson(json);
  Map<String, dynamic> toJson() => _$EventModelToJson(this);
}
