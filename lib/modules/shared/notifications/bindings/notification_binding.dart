import 'package:get/get.dart';
import '../../../data/providers/notification_provider.dart';
import '../../../data/repositories/notification_repository.dart';
import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationProvider());
    Get.lazyPut(() => NotificationRepository());
    Get.put(NotificationController()); // Dùng .put để controller luôn sống và lắng nghe realtime
  }
}