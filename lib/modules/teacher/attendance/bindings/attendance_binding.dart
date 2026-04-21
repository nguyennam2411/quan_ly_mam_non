import 'package:get/get.dart';
import 'package:quan_ly_mam_non/data/repositories/attendance_repository.dart';
import '../controllers/attendance_controller.dart';
import '../controllers/attendance_statistic_controller.dart';

class AttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => AttendanceRepository());
    Get.lazyPut(() => AttendanceController(repository: Get.find()));
    Get.lazyPut(() => AttendanceStatisticController(repository: Get.find()));
  }
}