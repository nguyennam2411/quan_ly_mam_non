import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/values/app_assets.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../../../../global_widgets/inputs/custom_text_field.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.horizontalPadding),
              child: Form(
                key: controller.formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Hình minh hoạ (Illustration)
                    Image.asset(
                      AppAssets.illustLogin,
                      height: AppConstants.logoSizeLarge,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                        AppAssets.icSchool,
                        width: AppConstants.logoSizeMedium,
                        height: AppConstants.logoSizeMedium,
                        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                      ),
                    ),
                    AppConstants.spacingS,
                    
                    // Tiêu đề (Headline)
                    Text(
                      AppStrings.loginTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppConstants.spacingS,

                    // Slogan (Body)
                    Text(
                      AppStrings.appSlogan,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    AppConstants.spacingL,

                    // Ô nhập Email
                    Obx(() => CustomTextField(
                      controller: controller.emailController,
                      hintText: AppStrings.emailHint,
                      keyboardType: TextInputType.emailAddress,
                      errorText: controller.emailError.value,
                      onChanged: controller.onEmailChanged,
                      prefixIcon: SvgPicture.asset(
                        AppAssets.icEmail,
                        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                        width: AppConstants.inputIconSize,
                        height: AppConstants.inputIconSize,
                      ),
                      validator: AppValidators.email,
                    )),
                    
                    // Ô nhập Mật khẩu
                    Obx(() => CustomTextField(
                      controller: controller.passwordController,
                      hintText: AppStrings.passwordHint,
                      errorText: controller.passwordError.value,
                      onChanged: controller.onPasswordChanged,
                      isPassword: true,
                      prefixIcon: SvgPicture.asset(
                        AppAssets.icLock,
                        colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                        width: AppConstants.inputIconSize,
                        height: AppConstants.inputIconSize,
                      ),
                      validator: AppValidators.password,
                    )),

                    // Nút Quên mật khẩu
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Get.toNamed(Routes.FORGOT_PASSWORD),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingS, vertical: AppConstants.paddingXS),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          AppStrings.forgotPasswordAction,
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    AppConstants.spacingL,

                    // Nút Đăng nhập
                    Obx(() => PrimaryButton(
                      text: AppStrings.loginButton,
                      isLoading: controller.isLoading.value,
                      onPressed: controller.login,
                    )),
                    
                    AppConstants.spacingL,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

