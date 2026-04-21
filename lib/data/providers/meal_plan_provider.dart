import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:quan_ly_mam_non/core/values/app_database.dart';

class MealPlanProvider {
  final _client = Supabase.instance.client;

  Future<List<Map<String, dynamic>>> getRawWeeklyMenu(String gradeId) async {
    return await _client
        .from(AppDatabase.tableMealPlans)
        .select()
        .eq(AppDatabase.colGradeId, gradeId)
        .order(AppDatabase.colDayOfWeek, ascending: true);
  }
}