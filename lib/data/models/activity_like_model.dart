import 'package:json_annotation/json_annotation.dart';

part 'activity_like_model.g.dart';

@JsonSerializable()
class ActivityLikeModel {
  final String id;
  @JsonKey(name: 'activity_log_id')
  final String activityLogId;
  @JsonKey(name: 'user_id')
  final String userId;
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  ActivityLikeModel({
    required this.id,
    required this.activityLogId,
    required this.userId,
    required this.createdAt,
  });

  factory ActivityLikeModel.fromJson(Map<String, dynamic> json) => _$ActivityLikeModelFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityLikeModelToJson(this);
}
