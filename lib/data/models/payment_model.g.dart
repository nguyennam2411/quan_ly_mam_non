// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PaymentModel _$PaymentModelFromJson(Map<String, dynamic> json) => PaymentModel(
  id: json['id'] as String?,
  invoiceId: json['invoice_id'] as String,
  method: json['method'] as String,
  amount: (json['amount'] as num).toDouble(),
  paidAt: json['paid_at'] == null
      ? null
      : DateTime.parse(json['paid_at'] as String),
);

Map<String, dynamic> _$PaymentModelToJson(PaymentModel instance) =>
    <String, dynamic>{
      'id': ?instance.id,
      'invoice_id': instance.invoiceId,
      'method': instance.method,
      'amount': instance.amount,
      'paid_at': ?instance.paidAt?.toIso8601String(),
    };
