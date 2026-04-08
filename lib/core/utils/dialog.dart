import 'package:flutter/material.dart';
import 'package:get/get.dart';
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

  static void hideLoading() {
    if (Get.isDialogOpen ?? false) Get.back();
  }
}