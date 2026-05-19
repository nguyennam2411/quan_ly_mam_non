import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/charts/app_bar_chart.dart';
import '../../../../global_widgets/charts/app_pie_chart.dart';
import '../controllers/attendance_statistic_controller.dart';

class AttendanceStatisticView extends GetView<AttendanceStatisticController> {
  const AttendanceStatisticView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(title: 'Thống kê chuyên cần'),
      body: Obx(() {
        if (controller.isLoading.value && controller.monthlyRawData.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: () async => controller.fetchAllData(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppConstants.paddingL),
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSectionHeader(AppStrings.statsMonthlyRatio),
                _buildTimeSelector(
                  DateFormat('MM/yyyy').format(controller.selectedMonth.value),
                  onPrev: () => controller.prevMonth(),
                  onNext: () => controller.nextMonth(),
                  onTap: () => _showMonthPicker(context),
                ),
                AppConstants.spacingM,
                _buildChartCard(
                  AppPieChart(
                    data: controller.monthlyChartData,
                    legendItems: controller.monthlyLegend,
                    noDataText: AppStrings.statsNoData,
                  ),
                ),
                
                AppConstants.spacingXL,
                
                _buildSectionHeader(AppStrings.statsWeeklyTrend),
                _buildTimeSelector(
                  '${DateFormat('dd/MM').format(controller.selectedWeek.value)} - ${DateFormat('dd/MM').format(controller.selectedWeek.value.add(const Duration(days: 4)))}',
                  onPrev: () => controller.prevWeek(),
                  onNext: () => controller.nextWeek(),
                  onTap: () => _showWeekPicker(context),
                ),
                AppConstants.spacingM,
                _buildChartCard(
                  AppBarChart(
                    groups: controller.weeklyChartGroups,
                    bottomLabels: const ['T2', 'T3', 'T4', 'T5', 'T6'],
                    maxY: controller.weeklyMaxY,
                    legendItems: controller.weeklyLegend,
                    noDataText: AppStrings.statsWeeklyNoData,
                  ),
                ),
                
                const SizedBox(height: AppConstants.paddingXXL),
              ],
            ),
          ),
        );
      }),
    );
  }
  Widget _buildSectionHeader(String title) {
    return Text(
      title, 
      style: Theme.of(Get.context!).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.onSurface,
          ),
    );
  }

  Widget _buildTimeSelector(String label, {required VoidCallback onPrev, required VoidCallback onNext, VoidCallback? onTap}) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLow,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onPrev,
            icon: const Icon(Icons.chevron_left, color: AppColors.primary),
            visualDensity: VisualDensity.compact,
          ),
          Expanded(
            child: InkWell(
              onTap: onTap,
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Text(
                  label,
                  textAlign: TextAlign.center,
                  style: Theme.of(Get.context!).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ),
            ),
          ),
          IconButton(
            onPressed: onNext,
            icon: const Icon(Icons.chevron_right, color: AppColors.primary),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }

  Widget _buildChartCard(Widget chart) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: chart,
    );
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedMonth.value,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'CHỌN THÁNG THỐNG KÊ',
    );
    if (picked != null) {
      controller.changeMonth(picked);
    }
  }

  Future<void> _showWeekPicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedWeek.value,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'CHỌN TUẦN THỐNG KÊ',
    );
    if (picked != null) {
      controller.changeWeek(picked);
    }
  }
}
