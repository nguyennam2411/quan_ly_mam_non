import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../../../../global_widgets/inputs/otp_input.dart';
import '../controllers/forgot_password_controller.dart';
import '../widgets/auth_header.dart';

class OtpVerificationView extends GetView<ForgotPasswordController> {
  const OtpVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: const CircleBackButton(),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // --- Phần Header: Illustration + Tiêu đề + Mô tả ---
              AuthHeader(
                title: AppStrings.otpTitle,
                icon: Icons.mark_email_read_rounded,
                descriptionWidget: RichText(
                  text: TextSpan(
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      color: AppColors.onSurfaceVariant,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: AppStrings.otpDesc),
                      TextSpan(
                        text: '\n${controller.emailController.text}',
                        style: const TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // --- OTP Input (6 ô) ---
              Center(
                child: OtpInput(
                  length: 6,
                  onCompleted: controller.verifyOTP,
                  controller: controller.otpController,
                ),
              ),

              // --- Lỗi OTP từ Server (nếu có) ---
              Obx(() => Container(
                height: 32, // Cố định chiều cao để không bị nhảy layout
                alignment: Alignment.center,
                child: controller.otpError.value != null
                    ? Text(
                        controller.otpError.value!,
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                        ),
                      )
                    : const SizedBox.shrink(),
              )),
              
              AppConstants.spacingL, 

              // --- Nút Xác nhận ---
              Obx(() => PrimaryButton(
                text: AppStrings.confirmOtpButton,
                isLoading: controller.isLoading.value,
                onPressed: () {
                  final otp = controller.otpController.text;
                  if (otp.length == 6) {
                    controller.verifyOTP(otp);
                  }
                },
              )),
              AppConstants.spacingXL,

              // --- Gửi lại mã ---
              Center(
                child: Obx(() {
                  final count = controller.resendCount.value;
                  return count > 0
                      ? RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: AppColors.onSurfaceVariant,
                            ),
                            children: [
                              const TextSpan(text: AppStrings.otpNotReceived),
                              const TextSpan(text: '  '),
                              TextSpan(
                                text: 'Gửi lại sau ${count}s',
                                style: const TextStyle(
                                  color: AppColors.outlineVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              AppStrings.otpNotReceived,
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: AppColors.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(width: 4),
                            TextButton(
                              onPressed: controller.sendResetCode,
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                padding: EdgeInsets.zero,
                                minimumSize: Size.zero,
                                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: const Text(
                                AppStrings.otpResend,
                                style: TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                          ],
                        );
                }),
              ),
              AppConstants.spacingL,
            ],
          ),
        ),
      ),
    );
  }
}


