import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/values/app_constants.dart';
import '../../../routes/app_routes.dart';

class SplashController extends GetxController {
  @override
  void onReady() {
    super.onReady();
    _startApp();
  }

  Future<void> _startApp() async {
    // Đợi cho đẹp giao diện Splash
    await Future.delayed(AppConstants.splashDelay);

    if (AuthService.to.isLoggedIn) {
      // Nếu đã login, cập nhật Role và vào Dashboard dùng chung
      await AuthService.to.refreshUserData();
      Get.offAllNamed(Routes.MAIN_DASHBOARD);
    } else {
      // Chưa login thì ra màn hình đăng nhập
      Get.offAllNamed(Routes.LOGIN);
    }
  }
}