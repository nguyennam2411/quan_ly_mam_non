import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/services/auth_service.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_strings.dart';
import 'package:quan_ly_mam_non/core/values/user_role.dart';

class ProfileView extends StatelessWidget {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.currentUser.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 32),

              // --- Header: Avatar + Tên + Email ---
              Center(
                child: Column(
                  children: [
                    // Avatar placeholder
                    CircleAvatar(
                      radius: 48,
                      backgroundColor: AppColors.primaryContainer,
                      child: Text(
                        _getInitials(user?.email ?? ''),
                        style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                          color: AppColors.onPrimaryContainer,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Obx(() => Text(
                      AuthService.to.userRole.value.isNotEmpty
                          ? _getRoleLabel(AuthService.to.userRole.value)
                          : 'Người dùng',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppColors.onSurface,
                        fontWeight: FontWeight.bold,
                      ),
                    )),
                    const SizedBox(height: 4),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // --- Dải thông tin (Surface Container) ---
              Container(
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    _buildInfoTile(
                      context,
                      icon: Icons.badge_outlined,
                      label: 'Vai trò',
                      value: Obx(() => Text(
                        _getRoleLabel(AuthService.to.userRole.value),
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      )),
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      context,
                      icon: Icons.email_outlined,
                      label: 'Email',
                      value: Text(
                        user?.email ?? '—',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(), // Đẩy nút Logout xuống cuối

              // --- Nút Đăng xuất ---
              _buildLogoutButton(context),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String label,
    required Widget value,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Icon(icon, size: 22, color: AppColors.primary),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                value,
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 54,
      color: AppColors.outlineVariant.withOpacity(0.5),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: () => _confirmLogout(context),
      icon: const Icon(Icons.logout_rounded, size: 20),
      label: const Text(
        'Đăng xuất',
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
      ),
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.error,
        side: BorderSide(color: AppColors.error.withOpacity(0.4)),
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(100), // pill-shape theo Design System
        ),
      ),
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerLowest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Đăng xuất?'),
        content: const Text('Bạn có chắc muốn đăng xuất khỏi tài khoản này không?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: Text('Huỷ', style: TextStyle(color: AppColors.onSurfaceVariant)),
          ),
          TextButton(
            onPressed: () {
              Get.back(); // Đóng dialog trước
              AuthService.to.signOut();
            },
            child: Text(
              'Đăng xuất',
              style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // --- Helpers ---
  String _getInitials(String email) {
    if (email.isEmpty) return '?';
    return email[0].toUpperCase();
  }

  String _getRoleLabel(String role) {
    switch (role.toUpperCase()) {
      case UserRole.teacher: return 'Giáo viên';
      case UserRole.parent: return 'Phụ huynh';
      case UserRole.admin: return 'Quản trị viên';
      default: return 'Người dùng';
    }
  }

}
