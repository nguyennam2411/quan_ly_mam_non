import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/values/app_strings.dart';
import '../../../core/values/app_assets.dart';
import '../../../core/values/app_constants.dart';
import '../../../global_widgets/dialogs/app_loading.dart';
import '../controllers/splash_controller.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              AppAssets.splashBackground,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const SizedBox(),
            ),
          ),
          
          // Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo
                Image.asset(
                  AppAssets.logoWhite,
                  width: AppConstants.logoSizeMedium,
                  height: AppConstants.logoSizeMedium,
                  errorBuilder: (context, error, stackTrace) => SvgPicture.asset(
                    AppAssets.icSchool,
                    width: AppConstants.logoSizeMedium,
                    height: AppConstants.logoSizeMedium,
                    colorFilter: const ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
                  ),
                ),
                AppConstants.spacingL,
                
                // Tên trường
                Text(
                  AppStrings.appName,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                ),
                AppConstants.spacingS,
                
                // Slogan
                Text(
                  AppStrings.appSlogan,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.primary.withValues(alpha: 0.9),
                        fontWeight: FontWeight.w500,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          
          // Loading Indicator ở phía dưới
          const Positioned(
            bottom: AppConstants.paddingXXXL,
            left: 0,
            right: 0,
            child: AppLoading(
              color: AppColors.primary,
              size: AppConstants.buttonIconSize,
            ),
          ),
        ],
      ),
    );
  }
}

