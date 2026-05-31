// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

InvoiceItemModel _$InvoiceItemModelFromJson(Map<String, dynamic> json) =>
    InvoiceItemModel(
      group: json['group'] as String,
      type: json['type'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num).toDouble(),
      days: (json['days'] as num?)?.toInt(),
      unitPrice: (json['unit_price'] as num?)?.toDouble(),
      absentDays: (json['absent_days'] as num?)?.toInt(),
    );

Map<String, dynamic> _$InvoiceItemModelToJson(InvoiceItemModel instance) =>
    <String, dynamic>{
      'group': instance.group,
      'type': instance.type,
      'name': instance.name,
      'amount': instance.amount,
      'days': ?instance.days,
      'unit_price': ?instance.unitPrice,
      'absent_days': ?instance.absentDays,
    };

InvoiceModel _$InvoiceModelFromJson(Map<String, dynamic> json) => InvoiceModel(
  id: json['id'] as String?,
  studentId: json['student_id'] as String,
  month: (json['month'] as num?)?.toInt(),
  year: (json['year'] as num?)?.toInt(),
  totalAmount: (json['total_amount'] as num).toDouble(),
  status: json['status'] as String,
  dueDate: json['due_date'] == null
      ? null
      : DateTime.parse(json['due_date'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  items:
      (json['items'] as List<dynamic>?)
          ?.map((e) => InvoiceItemModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
      [],
  student: json['students'] == null
      ? null
      : StudentModel.fromJson(json['students'] as Map<String, dynamic>),
);

Map<String, dynamic> _$InvoiceModelToJson(InvoiceModel instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'student_id': instance.studentId,
      'month': ?instance.month,
      'year': ?instance.year,
      'total_amount': instance.totalAmount,
      'status': instance.status,
      'due_date': ?instance.dueDate?.toIso8601String(),
      'created_at': ?instance.createdAt?.toIso8601String(),
      'items': instance.items,
    };
