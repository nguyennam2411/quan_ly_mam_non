import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../routes/app_routes.dart';

class TeacherHomeView extends StatelessWidget {
  const TeacherHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.to.currentUser.value;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Header
              Text(
                'Xin chào Giáo viên',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user?.email ?? '...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Attendance Status Card (Placeholder)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.secondaryContainer,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
              ),

              const SizedBox(height: 32),

              // Teacher Utilities
              _buildTeacherTools(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeacherTools(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Công cụ giáo viên',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 1.5,
          children: [
            _buildFeatureCard(
              Icons.how_to_reg_rounded, 
              'Điểm danh',
              onTap: () => Get.toNamed(Routes.ATTENDANCE_MAIN),
            ),
            _buildFeatureCard(
              Icons.event_busy_rounded, 
              'Đơn xin nghỉ',
              onTap: () => Get.toNamed(Routes.TEACHER_LEAVE_REQUEST),
            ),
            _buildFeatureCard(
              Icons.history_edu_rounded, 
              'Nhật ký hoạt động',
              onTap: () => Get.toNamed(Routes.TEACHER_ACTIVITY_LOG),
            ),
            _buildFeatureCard(
              Icons.restaurant_menu_rounded, 
              'Thực đơn',
              onTap: () => Get.toNamed(Routes.MEAL_PLAN, arguments: {
                'gradeId': AuthService.to.gradeId.value,
                'title': 'Thực đơn của lớp',
              }),
            ),
            _buildFeatureCard(Icons.edit_calendar_rounded, 'Lịch hoạt động'),
            _buildFeatureCard(
              Icons.health_and_safety_rounded,
              'Sức khoẻ bé',
              onTap: () => Get.toNamed(Routes.TEACHER_HEALTH),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFeatureCard(IconData icon, String label, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}
