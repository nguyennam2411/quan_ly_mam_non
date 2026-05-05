import 'package:json_annotation/json_annotation.dart';
import '../../../core/values/app_database.dart';
import '../../../core/utils/date_helper.dart';

part 'health_record_model.g.dart';

enum BmiCategory {
  underweight,
  normal,
  overweight,
  obese,
}

@JsonSerializable()
class HealthRecordModel {
  @JsonKey(name: AppDatabase.colId)
  final String id;
  
  @JsonKey(name: AppDatabase.colStudentId)
  final String studentId;
  
  @JsonKey(name: AppDatabase.colHeight)
  final double height; // đơn vị: m
  
  @JsonKey(name: AppDatabase.colWeight)
  final double weight; // đơn vị: kg
  
  @JsonKey(name: AppDatabase.colBmi)
  final double bmi;
  
  @JsonKey(name: AppDatabase.colDate, fromJson: DateHelper.parseUtc)
  final DateTime date;
  
  @JsonKey(name: AppDatabase.colTeacherId)
  final String? teacherId;
  
  @JsonKey(name: AppDatabase.colNote)
  final String? note;
  
  @JsonKey(name: AppDatabase.colCreatedAt, fromJson: DateHelper.parseUtc)
  final DateTime createdAt;

  // Tên bé từ join query (không lưu vào DB)
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? studentName;
  
  @JsonKey(includeToJson: false, includeFromJson: false)
  final String? studentAvatarUrl;

  HealthRecordModel({
    required this.id,
    required this.studentId,
    required this.height,
    required this.weight,
    required this.bmi,
    required this.date,
    required this.createdAt,
    this.teacherId,
    this.note,
    this.studentName,
    this.studentAvatarUrl,
  });

  /// Phân loại BMI theo chuẩn trẻ em
  BmiCategory get bmiCategory {
    if (bmi < 14.0) return BmiCategory.underweight;
    if (bmi < 18.5) return BmiCategory.normal;
    if (bmi < 22.0) return BmiCategory.overweight;
    return BmiCategory.obese;
  }

  String get bmiCategoryLabel {
    switch (bmiCategory) {
      case BmiCategory.underweight:
        return 'Suy dinh dưỡng';
      case BmiCategory.normal:
        return 'Bình thường';
      case BmiCategory.overweight:
        return 'Thừa cân';
      case BmiCategory.obese:
        return 'Béo phì';
    }
  }

  /// Tính BMI từ chiều cao (m) và cân nặng (kg)
  static double calculateBmi(double heightM, double weightKg) {
    if (heightM <= 0) return 0;
    return weightKg / (heightM * heightM);
  }

  factory HealthRecordModel.fromJson(Map<String, dynamic> json) {
    // Xử lý thủ công phần dữ liệu Join từ bảng Students
    String? sName;
    String? sAvatar;
    if (json[AppDatabase.tableStudents] != null) {
      sName = json[AppDatabase.tableStudents][AppDatabase.colName] as String?;
      sAvatar = json[AppDatabase.tableStudents][AppDatabase.colAvatarUrl] as String?;
    }

    // Sử dụng generated function từ .g.dart cho các trường cơ bản
    final model = _$HealthRecordModelFromJson(json);
    
    // Trả về model mới kèm dữ liệu join
    return HealthRecordModel(
      id: model.id,
      studentId: model.studentId,
      height: model.height,
      weight: model.weight,
      bmi: model.bmi,
      date: model.date,
      teacherId: model.teacherId,
      note: model.note,
      createdAt: model.createdAt,
      studentName: sName,
      studentAvatarUrl: sAvatar,
    );
  }

  Map<String, dynamic> toJson() => _$HealthRecordModelToJson(this);
}
