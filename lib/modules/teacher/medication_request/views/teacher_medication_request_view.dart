import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/headers/page_header.dart';
import '../../../../global_widgets/headers/section_header.dart';
import '../../../../global_widgets/inputs/app_search_bar.dart';
import '../../../../global_widgets/dialogs/app_loading.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../../../../global_widgets/chips/filter_tabs.dart';
import '../../../../global_widgets/medication_request/medication_request_card.dart';
import '../../../../global_widgets/medication_request/medication_request_detail_modal.dart';
import '../controllers/teacher_medication_request_controller.dart';

class TeacherMedicationRequestView extends GetView<TeacherMedicationRequestController> {
  const TeacherMedicationRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(title: 'Đơn dặn thuốc'),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: 'Đơn dặn thuốc',
              subtitle: 'Theo dõi và hướng dẫn cho trẻ uống thuốc trên lớp',
            ),
            _buildSearchAndFilter(context),
            const SizedBox(height: 16),
            _buildSeparatorSection(context),
            const SizedBox(height: 12),
            _buildRequestList(context),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Column(
      children: [
        // 1. Search Bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: AppSearchBar(
            hintText: 'Tìm học sinh...',
            onChanged: (value) => controller.searchQuery.value = value,
            height: 46,
            borderRadius: BorderRadius.circular(23),
            backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
            boxShadow: const [],
            iconSize: 22,
          ),
        ),
        AppConstants.spacingM,
        
        // 2. Status filter tabs
        Obx(() {
          final statuses = [
            AppStrings.leaveStatusAll,
            AppStrings.medicationStatusPending,
            AppStrings.medicationStatusCompleted,
            AppStrings.medicationStatusMedical,
          ];
          return FilterTabs(
            statuses: statuses,
            selectedStatus: controller.selectedStatus.value,
            onStatusChanged: (status) => controller.selectedStatus.value = status,
            statusCounts: controller.statusCounts,
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          );
        }),
      ],
    );
  }

  Widget _buildSeparatorSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
      child: SectionHeader(
        title: 'Danh sách đơn dặn thuốc',
        trailing: _buildSortButton(),
      ),
    );
  }

  Widget _buildSortButton() {
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: () => controller.toggleSortOrder(),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Obx(() => Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                controller.isDescending.value 
                    ? Icons.south_rounded 
                    : Icons.north_rounded,
                size: 18, 
                color: AppColors.primary,
              ),
              AppConstants.spacingXS,
              const Text(
                'Sắp xếp',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: AppColors.primary,
                ),
              ),
            ],
          )),
        ),
      ),
    );
  }

  Widget _buildRequestList(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: AppLoading(),
        );
      }

      final requests = controller.filteredRequests;

      if (requests.isEmpty) {
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 40.0),
          child: AppEmptyState(
            title: 'Không có đơn dặn thuốc nào',
            description: 'Không tìm thấy đơn dặn thuốc nào khớp với điều kiện lọc.',
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          final isPending = request.status == AppDatabase.pending;

          return AppMedicationRequestCard(
            request: request,
            onDetail: () {
              MedicationRequestDetailModal.show(
                request: request,
                isTeacher: true,
                onTransferMedical: isPending ? () => controller.transferToMedical(request.id!) : null,
                onComplete: isPending ? () => controller.markAsCompleted(request.id!) : null,
              );
            },
            actions: isPending
                ? Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _showConfirmDialog(
                          context, 
                          requestId: request.id!, 
                          actionType: 'medical',
                          title: 'Bạn có chắc chắn muốn chuyển trường hợp này xuống Y tế?',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.surfaceContainerHigh,
                          foregroundColor: AppColors.onSurfaceVariant,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMax),
                            side: const BorderSide(color: AppColors.outlineVariant, width: 0.5),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
                          minimumSize: const Size(0, 40),
                        ),
                        child: const Text(
                          'Chuyển Y tế',
                          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showConfirmDialog(
                          context, 
                          requestId: request.id!, 
                          actionType: 'complete',
                          title: 'Xác nhận đã cho bé uống thuốc thành công?',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.success,
                          foregroundColor: AppColors.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppConstants.radiusMax),
                          ),
                          padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL, vertical: 0),
                          minimumSize: const Size(0, AppConstants.inputMinHeight),
                        ),
                        child: const Text(
                          'Đã cho uống',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ),
                    ],
                  )
                : null,
          );
        },
      );
    });
  }

  void _showConfirmDialog(BuildContext context, {
    required String requestId, 
    required String actionType,
    required String title,
  }) {
    final isMedical = actionType == 'medical';

    AppDialogs.showConfirm(
      title: AppStrings.dialogConfirmTitle,
      message: title,
      agreeText: AppStrings.dialogAgree,
      agreeColor: isMedical ? AppColors.error : AppColors.primary,
      icon: isMedical ? Icons.warning_amber_rounded : Icons.check_circle_outline,
      iconColor: isMedical ? AppColors.error : AppColors.primary,
    ).then((confirm) {
      if (confirm) {
        if (isMedical) {
          controller.transferToMedical(requestId);
        } else {
          controller.markAsCompleted(requestId);
        }
      }
    });
  }
}
