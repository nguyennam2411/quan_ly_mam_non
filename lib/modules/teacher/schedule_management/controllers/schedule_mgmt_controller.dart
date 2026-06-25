import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/repositories/schedule_repository.dart';

import '../../../../core/utils/dialog.dart';
import '../../../../core/utils/app_error_message.dart';

class ScheduleMgmtController extends GetxController {
  final ScheduleRepository _repository;
  ScheduleMgmtController({required ScheduleRepository repository}) : _repository = repository;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<ScheduleItem> dailySchedule = <ScheduleItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Tải dữ liệu ban đầu
    fetchDailySchedule();
    // Xử lý Race Condition: Nếu classroomId chưa kịp load xong khi onInit, 
    // hàm này sẽ tự chạy lại ngay khi ID lớp học có giá trị.
    ever(AuthService.to.classroomId, (_) => fetchDailySchedule());
  }

  Future<void> fetchDailySchedule() async {
    final classroomId = AuthService.to.classroomId.value;
    if (classroomId.isEmpty) return;

    try {
      isLoading.value = true;
      final data = await _repository.getFullDailySchedule(classroomId, selectedDate.value);
      dailySchedule.assignAll(data);
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isLoading.value = false;
    }
  }

  // --- LUỒNG ĐIỀU HƯỚNG SANG SOẠN BÀI ---
  void goToLessonEditor(ScheduleItem? item) {
    // Nếu khung giờ này không cho phép soạn bài, bỏ qua
    if (item != null && !item.isLessonSlot) return;

    Get.toNamed(
      '/teacher/lesson-editor',
      arguments: {
        'date': selectedDate.value,
        'lesson': item?.lesson,
        'schedule': item?.schedule,
      },
    )?.then((result) {
      if (result == true) fetchDailySchedule();
    });
  }

  void onDateChanged(DateTime date) {
    selectedDate.value = date;
    fetchDailySchedule();
  }
}
