import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';

part 'payment_model.g.dart';

@JsonSerializable(includeIfNull: false)
class PaymentModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colInvoiceId)
  final String invoiceId;

  @JsonKey(name: 'method')
  final String method;

  @JsonKey(name: AppDatabase.colAmount)
  final double amount;

  @JsonKey(name: AppDatabase.colPaidAt)
  final DateTime? paidAt;

  PaymentModel({
    this.id,
    required this.invoiceId,
    required this.method,
    required this.amount,
    this.paidAt,
  });

  factory PaymentModel.fromJson(Map<String, dynamic> json) => _$PaymentModelFromJson(json);
  Map<String, dynamic> toJson() => _$PaymentModelToJson(this);
}
