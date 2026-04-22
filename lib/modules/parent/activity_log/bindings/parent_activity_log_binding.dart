import 'package:get/get.dart';
import '../../../../data/providers/activity_log_provider.dart';
import '../../../../data/repositories/activity_log_repository.dart';
import '../controllers/parent_activity_log_controller.dart';

class ParentActivityLogBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ActivityLogProvider());
    Get.lazyPut(() => ActivityLogRepository(Get.find<ActivityLogProvider>()));
    
    Get.lazyPut(() => ParentActivityLogController(
      repository: Get.find<ActivityLogRepository>(),
    ));
  }
}
