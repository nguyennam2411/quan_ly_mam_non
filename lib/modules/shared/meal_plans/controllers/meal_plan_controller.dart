import 'package:get/get.dart';
import '../../../../data/models/meal_plan_model.dart';
import '../../../../data/repositories/meal_plan_repository.dart';

class MealPlanController extends GetxController {
  final MealPlanRepository _repository = Get.find<MealPlanRepository>();

  final RxString gradeId = ''.obs;
  final RxString gradeName = 'Thực đơn'.obs;
  final RxBool isLoading = true.obs;
  final RxList<MealPlanModel> weeklyMenu = <MealPlanModel>[].obs;
  
  // Index ngày đang chọn (0: Thứ 2, 1: Thứ 3, ..., 4: Thứ 6)
  final RxInt selectedDayIndex = 0.obs;

  @override
  void onInit() {
    super.onInit();
    _handleArguments();
    _setDefaultDay();
    fetchWeeklyMenu();
  }

  void _handleArguments() {
    final args = Get.arguments;
    if (args != null && args is Map) {
      gradeId.value = args['gradeId'] ?? '';
      gradeName.value = args['title'] ?? 'Thực đơn';
    }
  }

  void _setDefaultDay() {
    // Lấy thứ hiện tại (1: Thứ 2, ..., 7: Chủ nhật)
    int weekday = DateTime.now().weekday;
    if (weekday >= 1 && weekday <= 5) {
      selectedDayIndex.value = weekday - 1;
    } else {
      selectedDayIndex.value = 0; // Mặc định về Thứ 2 nếu là cuối tuần
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
      Get.snackbar('Lỗi', 'Không thể tải thực đơn: $e');
    } finally {
      isLoading.value = false;
    }
  }

  MealPlanModel? get currentDayMenu {
    // Tìm thực đơn có dayOfWeek tương ứng (selectedDayIndex + 2)
    // Vì DB lưu: Thứ 2 = 2, Thứ 3 = 3...
    try {
      return weeklyMenu.firstWhere(
        (meal) => meal.dayOfWeek == selectedDayIndex.value + 2,
      );
    } catch (_) {
      return null;
    }
  }

  void changeDay(int index) {
    selectedDayIndex.value = index;
  }
}
