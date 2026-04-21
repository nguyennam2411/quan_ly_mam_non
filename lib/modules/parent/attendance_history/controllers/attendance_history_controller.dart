import 'package:get/get.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../data/models/attendance_model.dart';
import '../../../../data/repositories/attendance_repository.dart';

class AttendanceHistoryController extends GetxController {
  final AttendanceRepository _repository = Get.find<AttendanceRepository>();
  final _studentService = ParentStudentService.to;

  final RxList<AttendanceModel> absentList = <AttendanceModel>[].obs;
  final RxBool isLoading = false.obs;

  // Stats
  final RxInt totalExcused = 0.obs;
  final RxInt totalUnexcused = 0.obs;

  @override
  void onInit() {
    super.onInit();
    // Tải dữ liệu lần đầu
    fetchHistory();
    
    // Theo dõi thay đổi học sinh để tải lại data
    ever(_studentService.selectedStudent, (_) => fetchHistory());
  }

  Future<void> fetchHistory() async {
    final student = _studentService.selectedStudent.value;
    if (student == null) return;

    try {
      isLoading.value = true;
      final history = await _repository.getStudentAbsentHistory(student.id);
      absentList.assignAll(history);
      _calculateStats();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải lịch sử chuyên cần');
    } finally {
      isLoading.value = false;
    }
  }

  void _calculateStats() {
    int excused = 0;
    int unexcused = 0;

    for (var item in absentList) {
      if (item.status == 'ABSENT_EXCUSED') {
        excused++;
      } else if (item.status == 'ABSENT_UNEXCUSED') {
        unexcused++;
      }
    }

    totalExcused.value = excused;
    totalUnexcused.value = unexcused;
  }
}
