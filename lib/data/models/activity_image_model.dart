import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';

part 'activity_image_model.g.dart';

@JsonSerializable()
class ActivityImageModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colActivityId)
  final String? activityId;

  @JsonKey(name: AppDatabase.colImageUrl)
  final String imageUrl;

  ActivityImageModel({
    this.id,
    this.activityId,
    required this.imageUrl,
  });

  factory ActivityImageModel.fromJson(Map<String, dynamic> json) => _$ActivityImageModelFromJson(json);
  Map<String, dynamic> toJson() => _$ActivityImageModelToJson(this);
}
