import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../../../../global_widgets/inputs/app_search_bar.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../controllers/attendance_controller.dart';
import '../widgets/attendance_item_card.dart';
import '../widgets/attendance_summary_card.dart';

class AttendanceListView extends GetView<AttendanceController> {
  const AttendanceListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
      canPop: !controller.hasChanges.value, // Cho phép thoát nếu chưa có thay đổi
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
        appBar: MainAppBar(
          title: AppStrings.attendanceListTitle,
          actions: [
            if (!controller.isFuture)
              IconButton(
                onPressed: () => controller.markAllPresent(),
                icon: const Icon(Icons.done_all_rounded, color: AppColors.primary),
                tooltip: AppStrings.attendanceQuickAll,
              ),
            const SizedBox(width: 8),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              // 1. Summary Dashboard
              Padding(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Obx(() => AttendanceSummaryCard(
                  total: controller.studentsWithAttendance.length,
                  present: controller.presentCount,
                  absent: controller.absentCount,
                )),
              ),

              // 2. Search Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
                child: AppSearchBar(
                  hintText: AppStrings.attendanceSearchHint,
                  onChanged: (value) => controller.searchQuery.value = value,
                ),
              ),
              
              AppConstants.spacingM,
              
              // 3. List Section
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
                  
                  if (controller.filteredStudents.isEmpty) {
                    return AppEmptyState(
                      title: AppStrings.attendanceNotFound,
                      description: controller.searchQuery.value.isNotEmpty
                          ? '${AppStrings.attendanceSearchNoResults} "${controller.searchQuery.value}"'
                          : AppStrings.attendanceNoStudents,
                      icon: Icons.search_off_rounded,
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
                    itemCount: controller.filteredStudents.length,
                    physics: const BouncingScrollPhysics(),
                    itemBuilder: (context, index) {
                      final item = controller.filteredStudents[index];
                      final originalIndex = controller.studentsWithAttendance.indexOf(item);
                      
                      return AttendanceItemCard(
                        item: item,
                        isHistoryMode: controller.isFuture,
                        onStatusChanged: (status) => controller.updateStatus(originalIndex, status),
                      );
                    },
                  );
                }),
              ),

              // 4. Bottom Action
              if (!controller.isFuture)
                _buildBottomAction(),
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildBottomAction() {
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
        text: AppStrings.attendanceSubmit,
        trailingIcon: Icons.check_circle_outline,
        onPressed: () => controller.submitAttendance(),
      ),
    );
  }
}