import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/dialog.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../controllers/attendance_controller.dart';
import '../widgets/attendance_item_card.dart';

class AttendanceHistoryView extends GetView<AttendanceController> {
  const AttendanceHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
      canPop: !controller.hasChanges.value, // Chỉ chặn nếu thực sự có thay đổi chưa lưu
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await AppDialogs.showExitConfirm();
        if (shouldPop) {
          controller.hasChanges.value = false;
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const CircleBackButton(),
        title: Text(
          AppStrings.attendanceHistoryTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
        actions: [
          if (!controller.isFuture)
            Obx(() => IconButton(
              icon: Icon(
                controller.isEditMode.value ? Icons.lock_open_rounded : Icons.edit_note_rounded,
                color: AppColors.primary,
                size: 28,
              ),
              onPressed: () => controller.toggleEditMode(),
              tooltip: controller.isEditMode.value ? AppStrings.attendanceLockEdit : AppStrings.attendanceEnableEdit,
            )),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildHistoryHeader(context),
            
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return const Center(
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                    ),
                  );
                }

                if (controller.studentsWithAttendance.isEmpty) {
                  return AppEmptyState(
                    title: AppStrings.attendanceEmptyHistory,
                    description: 'Ngày ${DateFormat('dd/MM/yyyy').format(controller.selectedDate.value)} hiện chưa có bản ghi điểm danh nào.',
                    icon: Icons.history_toggle_off_rounded,
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
                  itemCount: controller.studentsWithAttendance.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final item = controller.studentsWithAttendance[index];
                    return Obx(() => AttendanceItemCard(
                      item: item,
                      isHistoryMode: !controller.isEditMode.value,
                      onStatusChanged: (status) => controller.updateStatus(index, status),
                    ));
                  },
                );
              }),
            ),

            Obx(() => controller.isEditMode.value 
              ? _buildSaveButton(context) 
              : const SizedBox.shrink()
            ),
          ],
        ),
      ),
    ),
  ));
}

  Widget _buildHistoryHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppConstants.paddingL),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppConstants.radiusXL),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.calendar_today_rounded, size: 20, color: AppColors.primary),
                const SizedBox(width: 10),
                Text(
                  DateFormat('EEEE, dd/MM/yyyy', 'vi').format(controller.selectedDate.value),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusMax),
              ),
              child: Obx(() => Text(
                '${AppStrings.attendanceStats}: ${controller.presentCount}/${controller.studentsWithAttendance.length}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return Container(
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
      child: PrimaryButton(
        text: AppStrings.attendanceSaveChange,
        onPressed: () => controller.submitAttendance(),
      ),
    );
  }
}