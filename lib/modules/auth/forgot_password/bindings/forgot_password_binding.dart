import 'package:get/get.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordBinding extends Bindings {
  @override
  void dependencies() {
    // Dùng fenix để controller không bị xóa khi nhảy giữa 3 màn hình views
    Get.lazyPut<ForgotPasswordController>(() => ForgotPasswordController(), fenix: true);
  }
}