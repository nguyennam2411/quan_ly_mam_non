import 'package:quan_ly_mam_non/core/values/app_database.dart';

class MealPlanModel {
  final String id;
  final String gradeId;
  final int dayOfWeek;
  final String breakfast;
  final String lunch;
  final String snack;
  final List<String> breakfastImg;
  final List<String> lunchImg;
  final List<String> snackImg;
  final String breakfastTime;
  final String lunchTime;
  final String snackTime;

  MealPlanModel({
    required this.id,
    required this.gradeId,
    required this.dayOfWeek,
    required this.breakfast,
    required this.lunch,
    required this.snack,
    this.breakfastImg = const [],
    this.lunchImg = const [],
    this.snackImg = const [],
    this.breakfastTime = '',
    this.lunchTime = '',
    this.snackTime = '',
  });

  factory MealPlanModel.fromJson(Map<String, dynamic> json) {
    return MealPlanModel(
      id: json[AppDatabase.colId],
      gradeId: json[AppDatabase.colGradeId],
      dayOfWeek: json[AppDatabase.colDayOfWeek],
      breakfast: json[AppDatabase.colBreakfast] ?? '',
      lunch: json[AppDatabase.colLunch] ?? '',
      snack: json[AppDatabase.colSnack] ?? '',
      breakfastImg: (json[AppDatabase.colBreakfastImg] as List?)?.map((e) => e.toString()).toList() ?? [],
      lunchImg: (json[AppDatabase.colLunchImg] as List?)?.map((e) => e.toString()).toList() ?? [],
      snackImg: (json[AppDatabase.colSnackImg] as List?)?.map((e) => e.toString()).toList() ?? [],
      breakfastTime: json[AppDatabase.colBreakfastTime] ?? '',
      lunchTime: json[AppDatabase.colLunchTime] ?? '',
      snackTime: json[AppDatabase.colSnackTime] ?? '',
    );
  }
}