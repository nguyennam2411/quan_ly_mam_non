import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/headers/page_header.dart';
import '../../../../global_widgets/inputs/app_search_bar.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../../../../global_widgets/leave_request/leave_request_filter_tabs.dart';
import '../../../../global_widgets/leave_request/leave_request_card.dart';
import '../controllers/teacher_leave_request_controller.dart';
import 'leave_request_detail_modal.dart';

class TeacherLeaveRequestView extends GetView<TeacherLeaveRequestController> {
  const TeacherLeaveRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(title: AppStrings.leaveRequestTeacherHeader),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const PageHeader(
            title: AppStrings.leaveRequestTeacherHeader,
            subtitle: AppStrings.leaveRequestTeacherSubtitle,
          ),
          _buildSearchAndFilter(context),
          const SizedBox(height: 16),
          _buildSeparatorSection(context),
          const SizedBox(height: 12),
          Expanded(child: _buildRequestList(context)),
        ],
      ),
    );
  }


  Widget _buildSearchAndFilter(BuildContext context) {
    return Column(
      children: [
        // 1. Thanh tìm kiếm chiếm toàn bộ chiều rộng ngang
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
          child: AppSearchBar(
            hintText: AppStrings.leaveRequestSearchHint,
            onChanged: (value) => controller.searchQuery.value = value,
            height: 46,
            borderRadius: BorderRadius.circular(23),
            backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
            boxShadow: const [],
            iconSize: 22,
          ),
        ),
        AppConstants.spacingM,
        
        // 2. Bộ lọc trạng thái 
        Obx(() => LeaveRequestFilterTabs(
          selectedStatus: controller.selectedStatus.value,
          onStatusChanged: (status) => controller.selectedStatus.value = status,
          statusCounts: controller.statusCounts,
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
        )),
      ],
    );
  }

  Widget _buildSeparatorSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bên trái: Tiêu đề Danh sách đơn nghỉ
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
                'Danh sách đơn nghỉ',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.onBackground.withValues(alpha: 0.9),
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          
          // Bên phải: Nút sắp xếp 
          _buildSortButton(),
        ],
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
              Text(
                AppStrings.leaveRequestSort,
                style: const TextStyle(
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
        return const Center(child: CircularProgressIndicator());
      }

      final requests = controller.filteredRequests;

      if (requests.isEmpty) {
        return const AppEmptyState(
          title: AppStrings.leaveRequestNoData,
          description: AppStrings.leaveRequestEmptyTeacher,
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
        itemCount: requests.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (context, index) {
          final request = requests[index];
          return AppLeaveRequestCard(
            request: request,
            onDetail: () {
              LeaveRequestDetailModal.show(request, onStatusUpdate: (status, {reason}) {
                controller.updateStatus(request.id!, status, reason: reason);
              });
            },
            actions: (request.status == AppDatabase.pending || request.status == AppDatabase.approved)
                ? Row(
                    children: [
                      ElevatedButton(
                        onPressed: () => _showConfirmDialog(
                          context, 
                          requestId: request.id!, 
                          status: AppDatabase.rejected,
                          title: request.status == AppDatabase.approved 
                              ? AppStrings.leaveRequestConfirmUndoApproval
                              : AppStrings.leaveRequestConfirmReject,
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
                        child: Text(
                          request.status == AppDatabase.approved 
                              ? AppStrings.leaveRequestUndoApproval
                              : AppStrings.leaveRequestReject,
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                      ),
                      if (request.status == AppDatabase.pending) ...[
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _showConfirmDialog(
                            context, 
                            requestId: request.id!, 
                            status: AppDatabase.approved,
                            title: AppStrings.leaveRequestConfirmApprove,
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: AppColors.onPrimary,
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusMax),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL, vertical: 0),
                            minimumSize: const Size(0, AppConstants.inputMinHeight),
                          ),
                          child: const Text(
                            AppStrings.leaveRequestApprove,
                            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                        ),
                      ],
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
    required String status,
    required String title,
  }) {
    final reasonController = TextEditingController();
    final isReject = status == AppDatabase.rejected;

    AppDialogs.showConfirm(
      title: AppStrings.dialogConfirmTitle,
      message: title,
      agreeText: AppStrings.dialogAgree,
      agreeColor: isReject ? AppColors.error : AppColors.primary,
      icon: isReject ? Icons.cancel_outlined : Icons.check_circle_outline,
      iconColor: isReject ? AppColors.error : AppColors.primary,
      customContent: isReject ? TextField(
        controller: reasonController,
        decoration: InputDecoration(
          hintText: AppStrings.leaveRequestCancelReasonHint,
          hintStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        maxLines: 2,
      ) : null,
    ).then((confirm) {
      if (confirm) {
        controller.updateStatus(
          requestId, 
          status, 
          reason: isReject ? reasonController.text.trim() : null
        );
      }
    });
  }
}
