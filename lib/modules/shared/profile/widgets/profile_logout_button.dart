import 'package:flutter/material.dart';
import 'package:quan_ly_mam_non/core/services/auth_service.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/utils/dialog.dart';
import 'package:quan_ly_mam_non/core/values/app_strings.dart';

/// Nút đăng xuất dạng viền đỏ mờ với hộp thoại xác nhận.
class ProfileLogoutButton extends StatelessWidget {
  const ProfileLogoutButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: _confirmLogout,
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.error,
            backgroundColor: AppColors.error.withValues(alpha: 0.04),
            side: BorderSide(
              color: AppColors.error.withValues(alpha: 0.2),
              width: 1.2,
            ),
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 0,
          ),
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text(
            AppStrings.profileLabelLogout,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ),
    );
  }

  void _confirmLogout() async {
    final confirm = await AppDialogs.showConfirm(
      message: AppStrings.profileConfirmLogoutMessage,
      agreeText: AppStrings.profileLabelLogout,
      agreeColor: AppColors.error,
    );
    if (confirm) {
      AuthService.to.signOut();
    }
  }
}
