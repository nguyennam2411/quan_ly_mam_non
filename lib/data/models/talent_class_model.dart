import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';

part 'talent_class_model.g.dart';

@JsonSerializable()
class TalentClassModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colName)
  final String name;

  @JsonKey(name: 'description')
  final String? description;

  @JsonKey(name: AppDatabase.colTeacherId)
  final String? teacherId;

  @JsonKey(name: AppDatabase.colFeePerMonth)
  final int feePerMonth;

  @JsonKey(name: AppDatabase.colScheduleInfo)
  final String scheduleInfo;

  @JsonKey(name: 'is_active')
  final bool isActive;

  @JsonKey(name: AppDatabase.colCreatedAt)
  final DateTime? createdAt;

  TalentClassModel({
    this.id,
    required this.name,
    this.description,
    this.teacherId,
    this.feePerMonth = 0,
    required this.scheduleInfo,
    this.isActive = true,
    this.createdAt,
  });

  factory TalentClassModel.fromJson(Map<String, dynamic> json) => _$TalentClassModelFromJson(json);
  Map<String, dynamic> toJson() => _$TalentClassModelToJson(this);
}
