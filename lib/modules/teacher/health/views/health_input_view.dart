import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
import '../controllers/health_controller.dart';

class HealthInputView extends GetView<HealthController> {
  const HealthInputView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const CircleBackButton(),
        title: Text(
          'Sức khoẻ & Phát triển',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          Obx(() => controller.isSaving.value
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                )
              : TextButton.icon(
                  onPressed: controller.saveAll,
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Lưu'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primary),
                )),
        ],
      ),
      body: Column(
        children: [
          _buildMonthSelector(context),
          _buildTableHeader(context),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.rows.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.people_outline_rounded,
                          size: 64, color: AppColors.outlineVariant),
                      AppConstants.spacingM,
                      const Text('Lớp chưa có học sinh nào'),
                    ],
                  ),
                );
              }
              return RefreshIndicator(
                onRefresh: controller.fetchData,
                child: ListView.builder(
                  itemCount: controller.rows.length,
                  itemBuilder: (context, index) =>
                      _buildStudentRow(context, index),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthSelector(BuildContext context) {
    return Obx(() {
      final month = controller.selectedMonth.value;
      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.chevron_left, color: AppColors.primary),
              onPressed: controller.prevMonth,
              visualDensity: VisualDensity.compact,
            ),
            InkWell(
              onTap: () => _showMonthPicker(context),
              child: Text(
                DateFormat('MM / yyyy').format(month),
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.primary,
                    ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.chevron_right, color: AppColors.primary),
              onPressed: controller.nextMonth,
              visualDensity: VisualDensity.compact,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildTableHeader(BuildContext context) {
    final style = Theme.of(context).textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: AppColors.onSurfaceVariant,
        );
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerLow,
        border: Border(bottom: BorderSide(color: AppColors.outlineVariant)),
      ),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Học sinh', style: style)),
          Expanded(flex: 2, child: Text('Cao (m)', style: style, textAlign: TextAlign.center)),
          Expanded(flex: 2, child: Text('Nặng (kg)', style: style, textAlign: TextAlign.center)),
          Expanded(flex: 3, child: Text('BMI / Phân loại', style: style, textAlign: TextAlign.center)),
        ],
      ),
    );
  }

  Widget _buildStudentRow(BuildContext context, int index) {
    final row = controller.rows[index];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: index.isEven ? AppColors.surface : AppColors.surfaceContainerLowest,
        border: const Border(bottom: BorderSide(color: AppColors.outlineVariant, width: 0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Tên học sinh
          Expanded(
            flex: 3,
            child: Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primaryContainer,
                  backgroundImage: row.avatarUrl != null
                      ? NetworkImage(row.avatarUrl!)
                      : null,
                  child: row.avatarUrl == null
                      ? Text(
                          row.studentName.isNotEmpty
                              ? row.studentName[0].toUpperCase()
                              : '?',
                          style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: AppColors.onPrimaryContainer),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    row.studentName,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
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
              controller.rows.value; // trigger rebuild
              final bmi = row.bmi;
              final label = row.bmiLabel;
              final bmiColor = _getBmiColor(label);

              return Column(
                children: [
                  Text(
                    bmi != null ? bmi.toStringAsFixed(1) : '—',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: bmi != null ? bmiColor : AppColors.outlineVariant,
                      fontSize: 15,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (bmi != null)
                    Container(
                      margin: const EdgeInsets.only(top: 2),
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: bmiColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: bmiColor,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              );
            }),
          ),
        ],
      ),
    );
  }

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
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(fontSize: 13, color: AppColors.outlineVariant),
          contentPadding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.outlineVariant),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
          ),
          filled: true,
          fillColor: AppColors.surfaceContainerLowest,
        ),
      ),
    );
  }

  Color _getBmiColor(String label) {
    switch (label) {
      case 'Bình thường':
        return AppColors.success;
      case 'Thừa cân':
        return AppColors.warning;
      case 'Suy dinh dưỡng':
      case 'Béo phì':
        return AppColors.error;
      default:
        return AppColors.outlineVariant;
    }
  }

  Future<void> _showMonthPicker(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: controller.selectedMonth.value,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      helpText: 'CHỌN THÁNG ĐO',
    );
    if (picked != null) {
      controller.changeMonth(picked);
    }
  }
}
