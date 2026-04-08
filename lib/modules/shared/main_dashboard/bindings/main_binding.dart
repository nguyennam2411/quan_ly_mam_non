import 'package:get/get.dart';
import '../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // Dùng fenix: true để controller không bị diệt khi chuyển tab nội bộ
    Get.lazyPut<MainController>(() => MainController(), fenix: true);
  }
}