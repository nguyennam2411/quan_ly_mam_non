import 'package:get/get.dart';
import '../../../../data/repositories/attendance_repository.dart';
import '../controllers/attendance_history_controller.dart';

class AttendanceHistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AttendanceRepository>(() => AttendanceRepository());
    Get.lazyPut<AttendanceHistoryController>(() => AttendanceHistoryController());
  }
}
