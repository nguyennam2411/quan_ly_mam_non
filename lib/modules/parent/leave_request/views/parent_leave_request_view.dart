import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/headers/page_header.dart';
import '../../../../global_widgets/headers/section_header.dart';
import '../../../../global_widgets/dialogs/app_loading.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../../../../global_widgets/leave_request/leave_request_filter_tabs.dart';
import '../../../../global_widgets/leave_request/leave_request_card.dart';
import '../controllers/parent_leave_request_controller.dart';
import 'parent_leave_request_detail.dart';

class ParentLeaveRequestView extends GetView<ParentLeaveRequestController> {
  const ParentLeaveRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(title: AppStrings.leaveRequestTitle),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const PageHeader(
              title: AppStrings.leaveRequestTitle,
              subtitle: AppStrings.leaveRequestSubtitle,
            ),
            _buildFilterAndSort(context),
            const SizedBox(height: 16),
            _buildSeparatorSection(context),
            const SizedBox(height: 12),
            _buildRequestList(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          controller.resetForm();
          Get.toNamed(Routes.PARENT_CREATE_LEAVE_REQUEST);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }
  
  Widget _buildFilterAndSort(BuildContext context) {
    return Obx(() => LeaveRequestFilterTabs(
      selectedStatus: controller.selectedStatus.value,
      onStatusChanged: (status) => controller.selectedStatus.value = status,
      statusCounts: controller.statusCounts,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
    ));
  }

  Widget _buildSeparatorSection(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
      child: SectionHeader(
        title: AppStrings.leaveRequestListTitle,
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
              Text(
                AppStrings.leaveRequestSort,
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
            title: AppStrings.leaveRequestNoData,
            description: AppStrings.leaveRequestEmptyParent,
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
          return AppLeaveRequestCard(
            request: request,
            onDetail: () => ParentLeaveRequestDetail.show(request),
            actions: (request.status == AppDatabase.pending || request.status == AppDatabase.approved)
                ? ElevatedButton(
                    onPressed: () => _showCancelConfirm(request.id ?? ''),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.8),
                      foregroundColor: AppColors.onPrimaryContainer,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppConstants.radiusMax),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM, vertical: 0),
                      minimumSize: const Size(0, AppConstants.inputMinHeight),
                    ),
                    child: const Text(
                      AppStrings.leaveRequestCancel,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  )
                : null,
          );
        },
      );
    });
  }

  void _showCancelConfirm(String requestId) {
    final reasonController = TextEditingController();
    
    AppDialogs.showConfirm(
      message: AppStrings.leaveRequestConfirmCancel,
      agreeText: AppStrings.dialogAgree,
      agreeColor: AppColors.error,
      customContent: TextField(
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
      ),
    ).then((confirm) {
      if (confirm) {
        final reason = reasonController.text.trim();
        controller.cancelRequest(
          requestId, 
          reason.isEmpty ? AppStrings.leaveRequestAutoCancel : reason
        );
      }
    });
  }
}
