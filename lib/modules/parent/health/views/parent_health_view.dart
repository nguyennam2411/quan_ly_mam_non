import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../data/models/health_record_model.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/headers/page_header.dart';
import '../../../../global_widgets/headers/section_header.dart';
import '../../../../global_widgets/charts/app_line_chart.dart';
import '../../../../global_widgets/dialogs/app_loading.dart';
import '../controllers/parent_health_controller.dart';

class ParentHealthView extends GetView<ParentHealthController> {
  const ParentHealthView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(title: AppStrings.healthTitle),
      body: Obx(() { 
        if (controller.isLoading.value) {
          return const AppLoading();
        }
        return RefreshIndicator( 
          onRefresh: controller.fetchHistory,
          child: SingleChildScrollView( 
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const PageHeader(
                  title: AppStrings.healthTitle,
                  subtitle: AppStrings.healthSubtitle,
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSummaryCard(context),
                      AppConstants.spacingXL,
                      _buildGrowthChart(context),
                      AppConstants.spacingXL,
                      _buildHistoryList(context, controller.history.toList()),
                    ],
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
  

  // Xây dựng thẻ tóm tắt
  Widget _buildSummaryCard(BuildContext context) {
    final latest = controller.latestRecord;
    if (latest == null) {
      return Container(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        ),
        child: const Center(
          child: Text(
            AppStrings.statsNoData,
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
        ),
      );
    }
    
    // Lấy màu sắc cho BMI
    final bmiColor = _bmiColor(latest.bmiCategoryLabel);
    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primary.withValues(alpha: 0.75)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monitor_heart_rounded, color: Colors.white70, size: 16),
              const SizedBox(width: 6),
              Text(
                '${AppStrings.healthLatestMeasurementPrefix}${DateFormat('dd/MM/yyyy').format(latest.date.toLocal())}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
            ],
          ),
          AppConstants.spacingM,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildMetricItem(AppStrings.labelHeight,
                  '${(latest.height * 100).toStringAsFixed(1)} cm', Icons.height_rounded),
              Container(width: 1, height: 48, color: Colors.white24),
              _buildMetricItem(AppStrings.labelWeight,
                  '${latest.weight.toStringAsFixed(1)} kg', Icons.monitor_weight_outlined),
              Container(width: 1, height: 48, color: Colors.white24),
              Column(
                children: [
                  Text(
                    latest.bmi.toStringAsFixed(1),
                    style: const TextStyle(
                        color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: bmiColor.withValues(alpha: 0.25),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: bmiColor.withValues(alpha: 0.6)),
                    ),
                    child: Text(
                      latest.bmiCategoryLabel,
                      style: TextStyle(
                          color: bmiColor, fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(AppStrings.labelBmi, style: TextStyle(color: Colors.white54, fontSize: 11)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Xây dựng thẻ hiển thị thông tin
  Widget _buildMetricItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(color: Colors.white60, fontSize: 11)),
      ],
    );
  }
  
  // Xây dựng biểu đồ tăng trưởng
  Widget _buildGrowthChart(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: AppStrings.healthGrowthChart),
        AppConstants.spacingM,
        Row(
          children: [
            _buildChartTab(context, 0, AppStrings.labelHeight, Icons.height_rounded),
            const SizedBox(width: 8),
            _buildChartTab(context, 1, AppStrings.labelWeight, Icons.monitor_weight_outlined),
          ],
        ),
        Obx(() => controller.isMissingInfo.value
            ? Container(
                margin: const EdgeInsets.only(top: AppConstants.paddingM),
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  border: Border.all(color: AppColors.warning.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded, color: AppColors.warning, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        AppStrings.healthMissingInfoWarning,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox.shrink()), 
        AppConstants.spacingM,
        Container(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Obx(() {
            final isHeight = controller.chartTab.value == 0;
            final lines = controller.buildChartLines(isHeight);
            final legend = controller.buildLegend(isHeight);

            if (controller.history.isEmpty) {
              return const SizedBox(
                height: 160,
                child: Center(
                  child: Text(AppStrings.healthNoChartData,
                      style: TextStyle(color: AppColors.onSurfaceVariant)),
                ),
              );
            }

            return AppLineChart(
              lines: lines,
              xTitle: controller.isMissingInfo.value ? AppStrings.healthMeasurementIndex : AppStrings.healthAgeInMonths,
              yTitle: isHeight ? 'cm' : 'kg',
              legendItems: legend,
              noDataText: AppStrings.healthNoChartData,
            );
          }),
        ),
      ],
    );
  }
  
  // Xây dựng tab chuyển đổi giữa chiều cao và cân nặng
  Widget _buildChartTab(BuildContext context, int index, String label, IconData icon) {
    return Expanded(
      child: Obx(() {
        final isSelected = controller.chartTab.value == index;
        return GestureDetector(
          onTap: () => controller.chartTab.value = index,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : AppColors.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16,
                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
                const SizedBox(width: 6),
                Text(label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                    )),
              ],
            ),
          ),
        );
      }),
    );
  }
  
  // Xây dựng danh sách lịch sử đo lường
  Widget _buildHistoryList(BuildContext context, List<HealthRecordModel> history) {
    if (history.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: AppStrings.healthHistoryTitle),
        AppConstants.spacingM,
        ...history.reversed.take(6).map((record) =>
            _buildHistoryItem(context, record)),
      ],
    );
  }
  
  // Xây dựng từng mục trong danh sách lịch sử
  Widget _buildHistoryItem(BuildContext context, HealthRecordModel record) {
    final bmiColor = _bmiColor(record.bmiCategoryLabel);
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryContainer.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.straighten_rounded, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DateFormat('dd/MM/yyyy').format(record.date.toLocal()),
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.onSurface,
                      ),
                ),
                const SizedBox(height: 2),
                Text(
                  '${(record.height * 100).toStringAsFixed(1)} cm  •  ${record.weight.toStringAsFixed(1)} kg',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                record.bmi.toStringAsFixed(1),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: bmiColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: bmiColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  record.bmiCategoryLabel,
                  style: TextStyle(fontSize: 10, color: bmiColor, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
  
  // Lấy màu sắc cho BMI
  Color _bmiColor(String label) {
    switch (label) {
      case AppStrings.healthBmiNormal:
        return AppColors.success;
      case AppStrings.healthBmiOverweight:
        return AppColors.warning;
      case AppStrings.healthBmiUnderweight:
      case AppStrings.healthBmiObese:
        return AppColors.error;
      default:
        return AppColors.onSurfaceVariant;
    }
  }
}
