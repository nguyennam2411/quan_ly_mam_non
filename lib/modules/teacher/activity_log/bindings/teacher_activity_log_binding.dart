import 'package:get/get.dart';
import '../../../../data/providers/activity_log_provider.dart';
import '../../../../data/providers/student_provider.dart';
import '../../../../data/repositories/activity_log_repository.dart';
import '../../../../data/repositories/student_repository.dart';
import '../controllers/teacher_activity_log_controller.dart';

class TeacherActivityLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ActivityLogProvider());
    Get.lazyPut(() => ActivityLogRepository(Get.find<ActivityLogProvider>()));
    Get.lazyPut(() => StudentProvider());
    Get.lazyPut(() => StudentRepository(Get.find<StudentProvider>()));
    
    Get.lazyPut(() => TeacherActivityLogController(
      repository: Get.find<ActivityLogRepository>(),
      studentRepository: Get.find<StudentRepository>(),
    ));
  }
}
