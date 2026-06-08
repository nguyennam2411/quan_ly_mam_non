import 'package:get/get.dart';
import '../../../../data/models/meal_plan_model.dart';
import '../../../../data/repositories/meal_plan_repository.dart';

import '../../../../core/utils/dialog.dart';
import '../../../../core/utils/app_error_message.dart';
import '../../../../core/values/app_strings.dart';

class MealPlanController extends GetxController {
  final MealPlanRepository _repository = Get.find<MealPlanRepository>();

  final RxString gradeId = ''.obs;
  final RxString gradeName = AppStrings.mealPlanTitle.obs;
  final RxBool isLoading = true.obs;
  final RxList<MealPlanModel> weeklyMenu = <MealPlanModel>[].obs;
  
  final Rx<DateTime> selectedDate = DateTime.now().obs;

  @override
  void onInit() {
    super.onInit();
    _handleArguments();
    fetchWeeklyMenu();
  }

  void _handleArguments() {
    final args = Get.arguments;
    if (args != null && args is Map) {
      gradeId.value = args['gradeId'] ?? '';
      gradeName.value = args['title'] ?? AppStrings.mealPlanTitle;
    }
  }

  Future<void> fetchWeeklyMenu() async {
    if (gradeId.isEmpty) {
      isLoading.value = false;
      return;
    }

    try {
      isLoading.value = true;
      final menu = await _repository.getWeeklyMenu(gradeId.value);
      weeklyMenu.value = menu;
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isLoading.value = false;
    }
  }

  MealPlanModel? get currentDayMenu {
    try {
      final weekday = selectedDate.value.weekday;
      final dbDayOfWeek = weekday == 7 ? 1 : weekday + 1;
      return weeklyMenu.firstWhere(
        (meal) => meal.dayOfWeek == dbDayOfWeek,
      );
    } catch (_) {
      return null;
    }
  }

  void onDateChanged(DateTime date) {
    selectedDate.value = date;
  }
}
