import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/values/app_constants.dart';
import '../../../../../core/values/app_database.dart';
import '../../../../../core/values/app_strings.dart';
import '../../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../../global_widgets/headers/page_header.dart';
import '../controllers/attendance_history_controller.dart';

class AttendanceHistoryView extends GetView<AttendanceHistoryController> {
  const AttendanceHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(title: AppStrings.attendanceHistoryTitle),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: AppStrings.attendanceHistoryTitle,
            subtitle: AppStrings.attendanceHistorySubtitle,
          ),
          _buildFilterBar(),
          const SizedBox(height: 16),
          _buildSeparatorSection(context),
          const SizedBox(height: 12),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.filteredAbsentList.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
                itemCount: controller.filteredAbsentList.length,
                separatorBuilder: (context, index) => AppConstants.spacingM,
                itemBuilder: (context, index) {
                  final item = controller.filteredAbsentList[index];
                  return _buildAbsentCard(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    return Obx(() {
      return Container(
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          children: [
            _buildFilterChip(
              label: 'Tất cả',
              count: controller.absentList.length,
              isSelected: controller.selectedFilter.value == AttendanceHistoryFilter.all,
              onTap: () => controller.selectedFilter.value = AttendanceHistoryFilter.all,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Có phép',
              count: controller.totalExcused.value,
              isSelected: controller.selectedFilter.value == AttendanceHistoryFilter.excused,
              onTap: () => controller.selectedFilter.value = AttendanceHistoryFilter.excused,
            ),
            const SizedBox(width: 8),
            _buildFilterChip(
              label: 'Không phép',
              count: controller.totalUnexcused.value,
              isSelected: controller.selectedFilter.value == AttendanceHistoryFilter.unexcused,
              onTap: () => controller.selectedFilter.value = AttendanceHistoryFilter.unexcused,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildFilterChip({
    required String label,
    required int count,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    const activeColor = AppColors.primary;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(19),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(
            color: isSelected ? activeColor : AppColors.outlineVariant.withValues(alpha: 0.4),
            width: 1.2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: isSelected ? activeColor : AppColors.onBackground.withValues(alpha: 0.7),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 13,
              ),
            ),
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: BoxDecoration(
                color: isSelected ? activeColor : AppColors.outlineVariant.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: isSelected ? Colors.white : AppColors.outline,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildSeparatorSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
      child: Row(
        children: [
          Container(
            width: 4.5,
            height: 18,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(2.5),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'Danh sách vắng mặt',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.onBackground.withValues(alpha: 0.9),
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildAbsentCard(dynamic item) {
    bool isExcused = item.status == AppDatabase.statusAbsentExcused;
    DateTime date = DateTime.parse(item.date);
    String dateStr = DateFormat('EEEE, dd/MM', 'vi').format(date);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(
          color: (isExcused ? AppColors.warning : AppColors.error).withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: (isExcused ? AppColors.warning : AppColors.error).withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(
            isExcused ? Icons.event_available_rounded : Icons.event_busy_rounded,
            color: isExcused ? AppColors.warning : AppColors.error,
          ),
        ),
        title: Text(
          dateStr,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: (isExcused ? AppColors.warning : AppColors.error).withOpacity(0.1),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isExcused ? 'Vắng có phép' : 'Vắng không phép',
                style: TextStyle(
                  fontSize: 11,
                  color: isExcused ? AppColors.warning : AppColors.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            if (item.note != null && item.note!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                item.note!,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.onSurface.withOpacity(0.7),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.verified_user_rounded, size: 80, color: AppColors.success.withOpacity(0.2)),
          AppConstants.spacingM,
          Text(
            'Chưa có ngày vắng mặt',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bé đi học rất chuyên cần!',
            style: TextStyle(color: AppColors.outline),
          ),
        ],
      ),
    );
  }
}
