import 'package:quan_ly_mam_non/data/models/meal_plan_model.dart';
import 'package:quan_ly_mam_non/data/providers/meal_plan_provider.dart';

class MealPlanRepository {
  final MealPlanProvider _provider = MealPlanProvider();

  Future<List<MealPlanModel>> getWeeklyMenu(String gradeId) async {
    final response = await _provider.getRawWeeklyMenu(gradeId);
    return response.map((e) => MealPlanModel.fromJson(e)).toList();
  }
}