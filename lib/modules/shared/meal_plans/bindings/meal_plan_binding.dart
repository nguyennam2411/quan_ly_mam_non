import 'package:get/get.dart';
import '../../../../data/repositories/meal_plan_repository.dart';
import '../controllers/meal_plan_controller.dart';

class MealPlanBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MealPlanRepository>(() => MealPlanRepository());
    Get.put(MealPlanController());
  }
}
