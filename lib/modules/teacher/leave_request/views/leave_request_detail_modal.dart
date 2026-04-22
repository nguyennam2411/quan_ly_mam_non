import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../data/models/leave_request_model.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../../../../global_widgets/chips/status_badge.dart';
import '../../../../global_widgets/dialogs/app_image_viewer.dart';
import '../../../../global_widgets/leave_request/leave_request_detail_content.dart';

class LeaveRequestDetailModal extends StatelessWidget {
  final LeaveRequestModel request;
  final Function(String, {String? reason}) onStatusUpdate;

  const LeaveRequestDetailModal({
    super.key,
    required this.request,
    required this.onStatusUpdate,
  });

  static void show(LeaveRequestModel request, {required Function(String, {String? reason}) onStatusUpdate}) {
    Get.bottomSheet(
      LeaveRequestDetailModal(request: request, onStatusUpdate: onStatusUpdate),
      isScrollControlled: true,
      backgroundColor: AppColors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppConstants.radiusXL),
          topRight: Radius.circular(AppConstants.radiusXL),
        ),
      ),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: AppConstants.paddingL),
                decoration: BoxDecoration(
                  color: AppColors.outlineVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            // Title
            Center(
              child: Text(
                AppStrings.leaveRequestDetailTitle,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            AppConstants.spacingL,

            LeaveRequestDetailContent(request: request),
            AppConstants.spacingXXL,

            // Actions
            _buildActions(context),
            AppConstants.spacingM,
          ],
        ),
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final bool isPending = request.status == AppDatabase.pending;
    final bool isApproved = request.status == AppDatabase.approved;

    return Column(
      children: [
        if (isPending) ...[
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _confirmAction(
                    context, 
                    status: AppDatabase.rejected, 
                    title: AppStrings.leaveRequestConfirmReject,
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                  ),
                  child: const Text(AppStrings.leaveRequestReject, 
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _confirmAction(
                    context, 
                    status: AppDatabase.approved, 
                    title: AppStrings.leaveRequestConfirmApprove,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                  ),
                  child: const Text(AppStrings.leaveRequestApprove, 
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
          AppConstants.spacingM,
        ] else if (isApproved) ...[
          SizedBox(
            width: double.infinity,
            height: 48, // Tương đương vertical padding 14
            child: OutlinedButton(
              onPressed: () => _confirmAction(
                context, 
                status: AppDatabase.rejected, 
                title: AppStrings.leaveRequestConfirmUndoApproval,
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: const BorderSide(color: AppColors.error),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                ),
              ),
              child: const Text(AppStrings.leaveRequestUndoApproval, 
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          AppConstants.spacingM,
        ],
        SizedBox(
          width: double.infinity,
          height: AppConstants.buttonHeight,
          child: ElevatedButton(
            onPressed: () => Get.back(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceContainerHigh,
              foregroundColor: AppColors.onSurface,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusL),
              ),
            ),
            child: const Text(
              AppStrings.leaveRequestClose,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmAction(BuildContext context, {required String status, required String title}) {
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
        Get.back(); // Đóng modal chi tiết
        onStatusUpdate(
          status, 
          reason: isReject ? reasonController.text.trim() : null
        );
      }
    });
  }
}
