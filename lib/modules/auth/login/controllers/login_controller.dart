import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthRepository _authRepo = AuthRepository();

  // Key để quản lý trạng thái của Form (validate)
  final formKey = GlobalKey<FormState>();
  
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  
  var isLoading = false.obs;
  var isPasswordVisible = false.obs;

  var emailError = RxnString();
  var passwordError = RxnString();
  final autovalidateMode = AutovalidateMode.disabled.obs;

  Future<void> login() async {
    print("Login button pressed"); // Debug log
    // Reset lỗi cũ từ Server
    emailError.value = null;
    passwordError.value = null;

    // 1. Kiểm tra Local (Syntax / Format) qua formKey
    if (formKey.currentState?.validate() != true) {
      autovalidateMode.value = AutovalidateMode.onUserInteraction;
      print("Validation failed");
      return;
    }

    isLoading.value = true;
    print("Starting sign in with: ${emailController.text}");
    try {
      // 2. Gọi Repository để thực hiện đăng nhập
      await _authRepo.signIn(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      // 3. Khởi tạo/Cập nhật Role trong AuthService
      await AuthService.to.refreshUserData();
      
      // 4. Điều hướng TẤT CẢ về Main Dashboard (Module dùng chung vừa tạo!)
      Get.offAllNamed(Routes.MAIN_DASHBOARD);
    } catch (e) {
      emailError.value = " "; // Hiện màu đỏ ở viền ô Email (không hiện chữ)
      passwordError.value = AppStrings.errorLoginFailed;
    } finally {
      isLoading.value = false;
    }
  }

  // --- HÀM XÓA LỖI KHI NGƯỜI DÙNG NHẬP LIỆU ---
  void onEmailChanged(String v) {
    if (emailError.value != null) emailError.value = null; // Xóa lỗi server
  }

  // Khi người dùng gõ vào ô Password
  void onPasswordChanged(String v) {
    if (passwordError.value != null) passwordError.value = null; // Xóa lỗi server
  }

  @override
  void onClose() {
    // KHÔNG dispose TextEditingControllers ở đây để tránh lỗi
    // "used after being disposed" trong quá trình exit animation.
    // GC sẽ tự giải phóng khi không còn reference trỏ đến.
    super.onClose();
  }
}