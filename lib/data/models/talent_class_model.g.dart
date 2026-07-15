// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'talent_class_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TalentClassModel _$TalentClassModelFromJson(Map<String, dynamic> json) =>
    TalentClassModel(
      id: json['id'] as String?,
      name: json['name'] as String,
      description: json['description'] as String?,
      teacherId: json['teacher_id'] as String?,
      feePerMonth: (json['fee_per_month'] as num?)?.toInt() ?? 0,
      scheduleInfo: json['schedule_info'] as String,
      status: json['status'] as String? ?? AppDatabase.statusActive,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$TalentClassModelToJson(TalentClassModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'teacher_id': instance.teacherId,
      'fee_per_month': instance.feePerMonth,
      'schedule_info': instance.scheduleInfo,
      'status': instance.status,
      'created_at': instance.createdAt?.toIso8601String(),
    };
