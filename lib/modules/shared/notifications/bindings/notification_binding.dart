import 'package:get/get.dart';
import 'package:quan_ly_mam_non/data/providers/notification_provider.dart';
import 'package:quan_ly_mam_non/data/repositories/notification_repository.dart';
import '../controllers/notification_controller.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => NotificationProvider());
    Get.lazyPut(() => NotificationRepository());
    Get.put(NotificationController()); // Dùng .put để controller luôn sống và lắng nghe realtime
  }
}