import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';
import 'student_model.dart';

part 'invoice_model.g.dart';

@JsonSerializable(includeIfNull: false)
class InvoiceItemModel {
  @JsonKey(name: 'group')
  final String group;
  
  @JsonKey(name: 'type')
  final String type;
  
  @JsonKey(name: 'name')
  final String name;
  
  @JsonKey(name: 'amount')
  final double amount;
  
  @JsonKey(name: 'days')
  final int? days;
  
  @JsonKey(name: 'unit_price')
  final double? unitPrice;

  @JsonKey(name: 'absent_days')
  final int? absentDays;

  InvoiceItemModel({
    required this.group,
    required this.type,
    required this.name,
    required this.amount,
    this.days,
    this.unitPrice,
    this.absentDays,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) => _$InvoiceItemModelFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceItemModelToJson(this);
}

@JsonSerializable(includeIfNull: false)
class InvoiceModel {
  @JsonKey(name: AppDatabase.colId)
  final String? id;

  @JsonKey(name: AppDatabase.colStudentId)
  final String studentId;

  @JsonKey(name: AppDatabase.colMonth)
  final int? month;

  @JsonKey(name: AppDatabase.colYear)
  final int? year;

  @JsonKey(name: AppDatabase.colTotalAmount)
  final double totalAmount;

  @JsonKey(name: AppDatabase.colStatus)
  final String status;

  @JsonKey(name: AppDatabase.colDueDate)
  final DateTime? dueDate;

  @JsonKey(name: AppDatabase.colCreatedAt)
  final DateTime? createdAt;

  @JsonKey(name: AppDatabase.colItems, defaultValue: [])
  final List<InvoiceItemModel> items;

  @JsonKey(name: AppDatabase.tableStudents, includeToJson: false)
  final StudentModel? student;

  InvoiceModel({
    this.id,
    required this.studentId,
    this.month,
    this.year,
    required this.totalAmount,
    required this.status,
    this.dueDate,
    this.createdAt,
    required this.items,
    this.student,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) => _$InvoiceModelFromJson(json);
  Map<String, dynamic> toJson() => _$InvoiceModelToJson(this);
}
