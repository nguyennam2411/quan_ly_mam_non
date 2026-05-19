import 'package:get/get.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../data/repositories/schedule_repository.dart';

class StudentScheduleController extends GetxController {
  final ScheduleRepository _repository;
  StudentScheduleController({required ScheduleRepository repository}) : _repository = repository;

  final Rx<DateTime> selectedDate = DateTime.now().obs;
  final RxList<ScheduleItem> dailySchedule = <ScheduleItem>[].obs;
  final RxBool isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Tải dữ liệu lần đầu
    fetchDailySchedule();
    // Tự động tải lại khi phụ huynh đổi chọn học sinh
    ever(ParentStudentService.to.selectedStudent, (_) => fetchDailySchedule());
  }

  Future<void> fetchDailySchedule() async {
    final student = ParentStudentService.to.selectedStudent.value;
    if (student == null || student.classroomId == null) {
      dailySchedule.clear();
      return;
    }

    try {
      isLoading.value = true;
      final data = await _repository.getFullDailySchedule(
        student.classroomId!, 
        selectedDate.value,
        isParent: true,
      );
      dailySchedule.assignAll(data);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải lịch học');
    } finally {
      isLoading.value = false;
    }
  }

  void onDateChanged(DateTime date) {
    selectedDate.value = date;
    fetchDailySchedule();
  }
}
