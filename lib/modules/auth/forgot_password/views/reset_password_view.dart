import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../../../../global_widgets/inputs/custom_text_field.dart';
import '../controllers/forgot_password_controller.dart';
import '../widgets/auth_header.dart';

class ResetPasswordView extends GetView<ForgotPasswordController> {
  const ResetPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        // Không cho back về OTP khi đã verify thành công
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Phần Header: Illustration + Tiêu đề + Mô tả ---
              AuthHeader(
                title: AppStrings.resetPasswordTitle,
                description: AppStrings.resetPasswordDesc,
                icon: Icons.lock_open_rounded,
              ),

              // --- Form ---
              Form(
                key: controller.resetFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Ô mật khẩu mới
                    CustomTextField(
                      controller: controller.newPasswordController,
                      hintText: AppStrings.newPasswordHint,
                      isPassword: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      validator: AppValidators.password,
                    ),
                    // Đã có khoảng trống giữ chỗ bên dưới CustomTextField
                    
                    // Ô xác nhận mật khẩu
                    CustomTextField(
                      controller: controller.confirmPasswordController,
                      hintText: AppStrings.confirmPasswordHint,
                      isPassword: true,
                      prefixIcon: const Icon(
                        Icons.lock_outline_rounded,
                        color: AppColors.primary,
                        size: 22,
                      ),
                      validator: (value) => AppValidators.confirmPassword(
                        value,
                        controller.newPasswordController.text,
                      ),
                    ),
                    // Giảm khoảng cách vì field đã có padding dưới
                    const SizedBox(height: 4),

                    // --- Hint nhỏ bên dưới ---
                    Center(
                      child: Text(
                        AppStrings.resetPasswordHint,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ),
                    AppConstants.spacingL,

                    // --- Nút Lưu mật khẩu ---
                    Obx(() => PrimaryButton(
                      text: AppStrings.resetPasswordButton,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.updatePassword,
                    )),
                  ],
                ),
              ),
              AppConstants.spacingL,
            ],
          ),
        ),
      ),
    );
  }
}

