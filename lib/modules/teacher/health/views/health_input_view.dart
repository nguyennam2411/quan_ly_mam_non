import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/headers/page_header.dart';
import '../../../../global_widgets/inputs/app_search_bar.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../../../../global_widgets/dialogs/app_loading.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../controllers/health_controller.dart';
import '../../../../core/values/app_strings.dart';

class HealthInputView extends GetView<HealthController> {
  const HealthInputView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(
        title: AppStrings.healthTitle,
      ),
      body: Column(
        children: [
          const PageHeader(
            title: AppStrings.healthTitle,
            subtitle: AppStrings.healthTeacherSubtitle,
          ),
          _buildSearchAndMonthSelector(context),
          const SizedBox(height: 8),
          _buildTableHeader(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoading();
              }
              if (controller.filteredRows.isEmpty) {
                return AppEmptyState(
                  title: controller.searchQuery.value.isNotEmpty
                      ? AppStrings.errorNoResults
                      : AppStrings.healthClassEmptyTitle,
                  description: controller.searchQuery.value.isNotEmpty
                      ? '${AppStrings.healthNoStudentMatch} "${controller.searchQuery.value}"'
                      : AppStrings.healthClassEmptyDesc,
                  icon: Icons.search_off_rounded,
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchData,
                child: ListView.builder(
                  itemCount: controller.filteredRows.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) =>
                      _buildStudentRow(context, index),
                ),
              );
            }),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(AppConstants.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radiusXL),
            topRight: Radius.circular(AppConstants.radiusXL),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 15,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Obx(() => PrimaryButton(
                text: AppStrings.healthSaveRecordButton,
                trailingIcon: Icons.check_circle_outline_rounded,
                isLoading: controller.isSaving.value,
                onPressed: controller.saveAll,
              )),
        ),
      ),
    );
  }

  // Xây dựng bộ chọn tháng và thanh tìm kiếm
  Widget _buildSearchAndMonthSelector(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Thanh tìm kiếm
          AppSearchBar(
            hintText: AppStrings.attendanceSearchHint,
            onChanged: (value) => controller.searchQuery.value = value,
            height: 46,
            borderRadius: BorderRadius.circular(23),
            backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
            boxShadow: const [],
            iconSize: 22,
          ),
          AppConstants.spacingM,
          
          // Bộ chọn tháng
          Obx(() {
            final month = controller.selectedMonth.value;
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left_rounded, color: AppColors.primary, size: 22),
                    onPressed: controller.prevMonth,
                    visualDensity: VisualDensity.compact,
                  ),
                  InkWell(
                    onTap: () => _showMonthPicker(context),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, size: 16, color: AppColors.primary),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('MM / yyyy').format(month),
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primary,
                                  letterSpacing: 0.5,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 22),
                    onPressed: controller.nextMonth,
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // Xây dựng bảng tiêu đề
  Widget _buildTableHeader(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.8),
          letterSpacing: 0.5,
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.4),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(flex: 4, child: Text(AppStrings.healthHeaderStudent, style: style)),
          Expanded(flex: 2, child: Text(AppStrings.healthHeaderHeight, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text(AppStrings.healthHeaderWeight, style: style, textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text(AppStrings.healthHeaderBmi, style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  // Xây dựng hàng hiển thị thông tin học sinh
  Widget _buildStudentRow(BuildContext context, int index) {
    final row = controller.filteredRows[index];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border(
          bottom: BorderSide(
            color: AppColors.outlineVariant.withValues(alpha: 0.25),
            width: 0.8,
          ),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tên học sinh
          Expanded(
            flex: 4,
            child: Text(
              row.studentName,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.onBackground,
              ),
              overflow: TextOverflow.ellipsis,
              maxLines: 2,
            ),
          ),

          // Chiều cao
          Expanded(
            flex: 2,
            child: _buildNumberField(
              controller: row.heightCtrl,
              hint: '0.00',
              onChanged: (_) => controller.rows.refresh(),
            ),
          ),

          // Cân nặng
          Expanded(
            flex: 2,
            child: _buildNumberField(
              controller: row.weightCtrl,
              hint: '0.0',
              onChanged: (_) => controller.rows.refresh(),
            ),
          ),

          // BMI & Phân loại
          Expanded(
            flex: 3,
            child: Obx(() {
              controller.rows.length; // trigger rebuild
              final bmi = row.bmi;
              final label = row.bmiLabel;
              final bmiColor = _getBmiColor(label);

              return Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    bmi != null ? bmi.toStringAsFixed(1) : '—',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: bmi != null ? bmiColor : AppColors.outlineVariant,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (bmi != null) ...[
                    const SizedBox(height: 3),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: bmiColor.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: bmiColor.withValues(alpha: 0.15),
                          width: 0.8,
                        ),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: bmiColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

  // Xây dựng ô nhập liệu
  Widget _buildNumberField({
    required TextEditingController controller,
    required String hint,
    required ValueChanged<String> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 14, 
          fontWeight: FontWeight.bold,
          color: AppColors.onBackground,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            fontSize: 13, 
            color: AppColors.outlineVariant.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.outlineVariant.withValues(alpha: 0.4),
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: AppColors.primary, 
              width: 1.5,
            ),
          ),
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
        ),
      ),
    );
  }

  // Lấy màu sắc cho BMI
  Color _getBmiColor(String label) {
    switch (label) {
      case AppStrings.healthBmiNormal:
        return AppColors.success;
      case AppStrings.healthBmiOverweight:
        return AppColors.warning;
      case AppStrings.healthBmiUnderweight:
      case AppStrings.healthBmiObese:
        return AppColors.error;
      default:
        return AppColors.outlineVariant;
    }
  }
  
  // Hiển thị hộp thoại chọn tháng
  Future<void> _showMonthPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedMonth.value,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: AppStrings.healthMonthPickerHelp,
    );
    if (picked != null) {
      controller.changeMonth(picked);
    }
  }
}
