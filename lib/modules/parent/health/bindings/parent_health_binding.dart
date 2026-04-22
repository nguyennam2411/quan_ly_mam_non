import 'package:get/get.dart';
import '../../../../data/providers/health_record_provider.dart';
import '../../../../data/repositories/health_record_repository.dart';
import '../controllers/parent_health_controller.dart';

class ParentHealthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HealthRecordRepository>(
      () => HealthRecordRepository(provider: HealthRecordProvider()),
    );
    Get.lazyPut<ParentHealthController>(
      () => ParentHealthController(repository: Get.find()),
    );
  }
}
