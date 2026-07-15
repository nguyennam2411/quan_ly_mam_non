import 'package:get/get.dart';
import '../controllers/teacher_talent_attendance_controller.dart';

class TeacherTalentAttendanceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherTalentAttendanceController>(() => TeacherTalentAttendanceController());
  }
}
