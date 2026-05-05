import 'package:get/get.dart';
import '../controllers/student_schedule_controller.dart';
import '../../../../data/repositories/schedule_repository.dart';

class StudentScheduleBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<StudentScheduleController>(
      () => StudentScheduleController(repository: ScheduleRepository()),
    );
  }
}
