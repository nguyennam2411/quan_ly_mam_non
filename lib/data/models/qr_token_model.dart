import 'package:json_annotation/json_annotation.dart';
import '../../core/values/app_database.dart';

part 'qr_token_model.g.dart';

@JsonSerializable()
class QrTokenModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colStudentId)
  final String studentId;

  @JsonKey(name: AppDatabase.colCode)
  final String code;

  QrTokenModel({
    this.id,
    required this.studentId,
    required this.code,
  });

  factory QrTokenModel.fromJson(Map<String, dynamic> json) => _$QrTokenModelFromJson(json);
  Map<String, dynamic> toJson() => _$QrTokenModelToJson(this);
}