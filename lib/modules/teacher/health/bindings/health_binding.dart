import 'package:get/get.dart';
import '../../../../data/providers/health_record_provider.dart';
import '../../../../data/repositories/health_record_repository.dart';
import '../controllers/health_controller.dart';

class HealthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HealthRecordRepository>(
      () => HealthRecordRepository(provider: HealthRecordProvider()),
    );
    Get.lazyPut<HealthController>(
      () => HealthController(repository: Get.find()),
    );
  }
}
