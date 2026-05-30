import 'package:get/get.dart';
import '../controllers/schedule_mgmt_controller.dart';
import '../controllers/lesson_editor_controller.dart';
import '../../../../data/repositories/schedule_repository.dart';
import '../../../../data/repositories/lesson_repository.dart';
import '../../../../data/providers/schedule_provider.dart';
import '../../../../data/providers/lesson_provider.dart';

class ScheduleMgmtBinding extends Bindings {
  @override
  void dependencies() {
    // Providers
    Get.lazyPut<ScheduleProvider>(() => ScheduleProvider());
    Get.lazyPut<LessonProvider>(() => LessonProvider());

    // Repositories
    Get.lazyPut<ScheduleRepository>(() => ScheduleRepository());
    Get.lazyPut<LessonRepository>(() => LessonRepository());

    // Controllers
    Get.lazyPut<ScheduleMgmtController>(
      () => ScheduleMgmtController(repository: Get.find<ScheduleRepository>()),
    );
    Get.lazyPut<LessonEditorController>(
      () => LessonEditorController(repository: Get.find<LessonRepository>()),
    );
  }
}
