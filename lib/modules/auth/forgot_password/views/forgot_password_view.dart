import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/values/app_assets.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../../../../global_widgets/inputs/custom_text_field.dart';
import '../controllers/forgot_password_controller.dart';
import '../widgets/auth_header.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

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
                title: AppStrings.forgotPasswordTitle,
                description: AppStrings.forgotPasswordDesc,
                icon: Icons.lock_reset_rounded,
              ),

              Obx(() => Form(
                autovalidateMode: controller.emailAutovalidateMode.value,
                key: controller.emailFormKey,
                child: Column(
                  children: [
                    // --- Ô nhập Email (reactive error từ Server) ---
                    Obx(() => CustomTextField(
                      controller: controller.emailController,
                      hintText: AppStrings.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      errorText: controller.emailError.value,
                      onChanged: (_) {
                        if (controller.emailError.value != null) {
                          controller.emailError.value = null;
                        }
                      },
                      prefixIcon: SvgPicture.asset(
                        AppAssets.icEmail,
                        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                        width: 24,
                        height: 24,
                      ),
                      validator: AppValidators.email,
                    )),
                    
                    AppConstants.spacingS,

                    // --- Nút Gửi OTP ---
                    Obx(() => PrimaryButton(
                      text: AppStrings.sendOtpButton,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.sendResetCode,
                    )),
                  ],
                ),
              )),

              AppConstants.spacingXL,

              // --- Dòng hỗ trợ (Stitch design: "Bạn cần hỗ trợ?") ---
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.needHelp,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(width: 4),
                  TextButton(
                    onPressed: () {
                      // TODO: Mở dialer hoặc màn hình hỗ trợ
                    },
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      AppStrings.contactSupport,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              AppConstants.spacingL,
            ],
          ),
        ),
      ),
    );
  }
}

