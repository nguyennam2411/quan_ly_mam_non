import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../theme/app_colors.dart';
import '../values/app_constants.dart';
import '../values/app_strings.dart';
import '../../global_widgets/dialogs/app_loading.dart';

class AppDialogs {
  static void showLoading() {
    Get.dialog(
      const PopScope(
        canPop: false, // Ngăn bấm back để thoát
        child: Center(
          child: AppLoading(color: Colors.white),
        ),
      ),
      barrierDismissible: false,
      barrierColor: Colors.black54, // Làm tối nền
    );
  }

  // Snackbar Thông báo thành công
  static void success({String? title, required String message}) {
    Get.snackbar(
      title ?? AppStrings.successTitle,
      message,
      backgroundColor: Colors.green.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(AppConstants.paddingM),
      borderRadius: AppConstants.radiusM,
      icon: const Icon(Icons.check_circle_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  // Snackbar Thông báo lỗi
  static void error({String? title, required String message}) {
    Get.snackbar(
      title ?? AppStrings.errorTitle,
      message,
      backgroundColor: Colors.redAccent.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(AppConstants.paddingM),
      borderRadius: AppConstants.radiusM,
      icon: const Icon(Icons.error_outline, color: Colors.white),
      duration: const Duration(seconds: 4),
    );
  }

  // Snackbar Thông báo cảnh báo
  static void warning({String? title, required String message}) {
    Get.snackbar(
      title ?? AppStrings.attendanceWarning,
      message,
      backgroundColor: Colors.orange.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(AppConstants.paddingM),
      borderRadius: AppConstants.radiusM,
      icon: const Icon(Icons.warning_amber_rounded, color: Colors.white),
      duration: const Duration(milliseconds: 3500),
    );
  }

  // Snackbar Thông báo thông tin
  static void info({String? title, required String message}) {
    Get.snackbar(
      title ?? AppStrings.attendanceNotice,
      message,
      backgroundColor: AppColors.primary.withValues(alpha: 0.9),
      colorText: Colors.white,
      snackPosition: SnackPosition.TOP,
      margin: const EdgeInsets.all(AppConstants.paddingM),
      borderRadius: AppConstants.radiusM,
      icon: const Icon(Icons.info_outline, color: Colors.white),
      duration: const Duration(seconds: 3),
    );
  }

  static void hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }

  // Hộp thoại xác nhận dùng chung
  static Future<bool> showConfirm({
    String? title,
    required String message,
    String? agreeText,
    String? cancelText,
    Color? agreeColor,
    IconData? icon,
    Color? iconColor,
    Widget? customContent,
  }) async {
    final result = await Get.dialog<bool>(
      AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusL),
        ),
        backgroundColor: AppColors.surface,
        title: Row(
          children: [
            Icon(
              icon ?? Icons.help_outline,
              color: iconColor ?? AppColors.primary,
            ),
            const SizedBox(width: 10),
            Text(
              title ?? AppStrings.dialogConfirmTitle,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message,
              style: const TextStyle(fontSize: 16),
            ),
            if (customContent != null) ...[
              const SizedBox(height: 16),
              customContent,
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: Text(
              cancelText ?? AppStrings.dialogCancel,
              style: const TextStyle(color: AppColors.outline),
            ),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: agreeColor ?? AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
              ),
            ),
            child: Text(agreeText ?? AppStrings.dialogAgree),
          ),
        ],
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  // Hộp thoại cảnh báo thoát khi chưa lưu
  static Future<bool> showExitConfirm() async {
    return await showConfirm(
      title: AppStrings.dialogExitTitle,
      message: AppStrings.dialogExitMessage,
      icon: Icons.warning_amber_rounded,
      iconColor: Colors.orange,
      agreeColor: Colors.redAccent,
    );
  }

  // Hộp thoại BottomSheet chọn nguồn ảnh dùng chung cho toàn bộ app
  static Future<ImageSource?> showImageSourcePicker({String? title}) async {
    return await Get.bottomSheet<ImageSource>(
      Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: Text(
                  title ?? 'Chọn hình ảnh',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.onSurface,
                  ),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.primary),
                title: const Text('Chụp ảnh mới'),
                onTap: () => Get.back(result: ImageSource.camera),
              ),
              const Divider(height: 1, indent: 56, endIndent: 16),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.primary),
                title: const Text('Chọn từ thư viện'),
                onTap: () => Get.back(result: ImageSource.gallery),
              ),
            ],
          ),
        ),
      ),
      backgroundColor: Colors.transparent,
    );
  }
}