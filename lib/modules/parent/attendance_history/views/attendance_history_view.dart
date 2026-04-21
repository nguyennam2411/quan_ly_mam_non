import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../../core/theme/app_colors.dart';
import '../../../../../core/values/app_constants.dart';
import '../../../../../core/values/app_database.dart';
import '../../../../../global_widgets/buttons/circle_back_button.dart';
import '../controllers/attendance_history_controller.dart';

class AttendanceHistoryView extends GetView<AttendanceHistoryController> {
  const AttendanceHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const CircleBackButton(),
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Chuyên cần',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.onBackground,
              ),
        ),
      ),
      body: Column(
        children: [
          _buildStatsHeader(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              if (controller.absentList.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.separated(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                itemCount: controller.absentList.length,
                separatorBuilder: (context, index) => AppConstants.spacingM,
                itemBuilder: (context, index) {
                  final item = controller.absentList[index];
                  return _buildAbsentCard(item);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsHeader() {
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      margin: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem('Tổng vắng', controller.absentList.length.toString(), Colors.white),
          Container(width: 1, height: 40, color: Colors.white24),
          Obx(() => _buildStatItem('Có phép', controller.totalExcused.value.toString(), Colors.white)),
          Container(width: 1, height: 40, color: Colors.white24),
          Obx(() => _buildStatItem('Không phép', controller.totalUnexcused.value.toString(), Colors.white)),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: color.withOpacity(0.8),
          ),
        ),
      ],
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
