import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../routes/app_routes.dart';

class ForgotPasswordController extends GetxController {
  final _supabase = Supabase.instance.client;

  // --- FORM KEYS ---
  final emailFormKey = GlobalKey<FormState>();
  final resetFormKey = GlobalKey<FormState>();

  // --- TEXT CONTROLLERS ---
  final emailController = TextEditingController();
  final otpController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  // --- TRẠNG THÁI REACTIVE ---
  var isLoading = false.obs;
  var emailError = RxnString();
  var otpError = RxnString();
  
  // Logic đếm ngược OTP
  Timer? _timer;
  var resendCount = 0.obs;

  // BƯỚC 1: GỬI MÃ XÁC NHẬN
  Future<void> sendResetCode() async {
    if (!emailFormKey.currentState!.validate()) return;
    
    isLoading.value = true;
    emailError.value = null;
    
    try {
      await _supabase.auth.resetPasswordForEmail(emailController.text.trim());
      _startTimer();
      Get.toNamed(Routes.OTP_VERIFY);
    } catch (e) {
      emailError.value = AppStrings.errorEmailNotFound;
    } finally {
      isLoading.value = false;
    }
  }

  // BƯỚC 2: XÁC THỰC OTP
  Future<void> verifyOTP(String code) async {
    isLoading.value = true;
    otpError.value = null;
    try {
      await _supabase.auth.verifyOTP(
        email: emailController.text.trim(),
        token: code,
        type: OtpType.recovery,
      );
      Get.toNamed(Routes.RESET_PASSWORD);
    } catch (e) {
      otpError.value = AppStrings.errorInvalidOtp;
    } finally {
      isLoading.value = false;
    }
  }

  // BƯỚC 3: CẬP NHẬT MẬT KHẨU MỚI
  Future<void> updatePassword() async {
    if (!resetFormKey.currentState!.validate()) return;

    isLoading.value = true;
    try {
      await _supabase.auth.updateUser(
        UserAttributes(password: newPasswordController.text.trim()),
      );

      isLoading.value = false;

      Get.offAllNamed(Routes.LOGIN);
      _showSuccessNotification();

    } catch (e) {
      isLoading.value = false;
      Get.snackbar(
        AppStrings.errorTitle, 
        AppStrings.errorUpdatePassword,
        backgroundColor: AppColors.errorContainer,
        colorText: AppColors.onErrorContainer,
      );
    }
  }

  // --- HÀM HỖ TRỢ ---
  void _showSuccessNotification() {
    Get.snackbar(
      AppStrings.successTitle,
      AppStrings.successUpdatePassword,
      backgroundColor: AppColors.successContainer,
      colorText: AppColors.success,
      snackPosition: SnackPosition.TOP,
      duration: AppConstants.snackbarDuration,
      margin: const EdgeInsets.all(AppConstants.paddingM),
      icon: const Icon(Icons.check_circle, color: AppColors.success),
    );
  }

  void _startTimer() {
    resendCount.value = AppConstants.otpCountdownSeconds;
    _timer?.cancel();
    _timer = Timer.periodic(AppConstants.timerPeriodic, (timer) {
      if (resendCount.value > 0) resendCount.value--;
      else _timer?.cancel();
    });
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}