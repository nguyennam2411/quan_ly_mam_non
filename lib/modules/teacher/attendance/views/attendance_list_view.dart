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
import '../../../../routes/app_routes.dart';

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
        appBar: const MainAppBar(
          title: AppStrings.attendanceListTitle,
        ),
        body: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: AppConstants.paddingL),
              
              // 2. Search Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
                child: AppSearchBar(
                  hintText: AppStrings.attendanceSearchHint,
                  onChanged: (value) => controller.searchQuery.value = value,
                  height: 46,
                  borderRadius: BorderRadius.circular(23),
                  backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
                  boxShadow: const [],
                  iconSize: 22,
                ),
              ),
              
              const SizedBox(height: 8),
              
              // 2.5. Status Filter Badges (Như hình)
              _buildFilterSection(),
              
              const SizedBox(height: 16),
              
              // 2.7. Separator and Quick Action (DS Học Sinh & Điểm danh tất cả)
              _buildSeparatorSection(context),
              
              const SizedBox(height: 12),
              
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

  Widget _buildFilterSection() {
    return Obx(() => SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildFilterItem(
            filter: AttendanceFilter.all,
            label: 'Tất cả',
            count: controller.allFilterCount,
          ),
          const SizedBox(width: 8),
          _buildFilterItem(
            filter: AttendanceFilter.notTaken,
            label: 'Chưa điểm danh',
            count: controller.notTakenFilterCount,
          ),
          const SizedBox(width: 8),
          _buildFilterItem(
            filter: AttendanceFilter.present,
            label: 'Có mặt',
            count: controller.presentFilterCount,
          ),
          const SizedBox(width: 8),
          _buildFilterItem(
            filter: AttendanceFilter.absent,
            label: 'Vắng',
            count: controller.absentFilterCount,
          ),
        ],
      ),
    ));
  }

  Widget _buildFilterItem({
    required AttendanceFilter filter,
    required String label,
    required int count,
  }) {
    final isSelected = controller.selectedFilter.value == filter;
    final activeColor = AppColors.primary;
    
    return InkWell(
      onTap: () => controller.selectedFilter.value = filter,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
          borderRadius: BorderRadius.circular(18),
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
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bên trái: Tiêu đề Danh sách học sinh nổi bật hơn với vạch đứng dày và cao hơn
          Row(
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
                'Danh sách học sinh',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground.withValues(alpha: 0.9),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          
          // Bên phải: Nút điểm danh tất cả được đóng gói thành dạng Chip có màu nền mỏng sang trọng
          if (!controller.isFuture)
            TextButton.icon(
              onPressed: () => controller.markAllPresent(),
              icon: const Icon(Icons.done_all_rounded, size: 18, color: AppColors.primary),
              label: const Text(
                'Điểm danh',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                backgroundColor: AppColors.primary.withValues(alpha: 0.08),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
        ],
      ),
    );
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
      child: Row(
        children: [
          // Nút xác nhận điểm danh - chiếm phần lớn chiều rộng
          Expanded(
            child: PrimaryButton(
              text: AppStrings.attendanceSubmit,
              trailingIcon: Icons.check_circle_outline,
              onPressed: () => controller.submitAttendance(),
            ),
          ),

          // Nút quét QR - chỉ hiện khi điểm danh hôm nay
          if (controller.isToday) ...[
            const SizedBox(width: AppConstants.paddingM),
            SizedBox(
              height: AppConstants.buttonHeight,
              width: AppConstants.buttonHeight,
              child: OutlinedButton(
                onPressed: () async {
                  final result = await Get.toNamed(Routes.ATTENDANCE_QR);
                  if (result == true) {
                    controller.fetchAttendanceList();
                  }
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary, width: 2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  padding: EdgeInsets.zero,
                ),
                child: const Icon(
                  Icons.qr_code_scanner_rounded,
                  color: AppColors.primary,
                  size: 26,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}