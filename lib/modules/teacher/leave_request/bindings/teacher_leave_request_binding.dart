import 'package:get/get.dart';
import '../../../../data/repositories/leave_request_repository.dart';
import '../controllers/teacher_leave_request_controller.dart';

class TeacherLeaveRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LeaveRequestRepository());
    Get.lazyPut(() => TeacherLeaveRequestController(repository: Get.find()));
  }
}