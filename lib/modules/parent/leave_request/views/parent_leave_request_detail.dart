import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../data/models/leave_request_model.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../../../../global_widgets/leave_request/leave_request_detail_content.dart';
import '../controllers/parent_leave_request_controller.dart';

class ParentLeaveRequestDetail extends StatelessWidget {
  final LeaveRequestModel request;

  const ParentLeaveRequestDetail({
    super.key,
    required this.request,
  });

  static void show(LeaveRequestModel request) {
    Get.bottomSheet(
      ParentLeaveRequestDetail(request: request),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nút kéo xuống giả (handle)
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
          
          // Tiêu đề
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

          // Hệ thống nút bấm
          _buildActions(context),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context) {
    final controller = Get.find<ParentLeaveRequestController>();
    final canCancel = request.status == AppDatabase.pending || 
                      request.status == AppDatabase.approved;

    return Column(
      children: [
        PrimaryButton(
          text: AppStrings.leaveRequestClose,
          onPressed: () => Get.back(),
        ),
        if (canCancel) ...[
          AppConstants.spacingS,
          TextButton(
            onPressed: () => _showCancelConfirm(context, controller),
            child: Text(
              AppStrings.leaveRequestCancel,
              style: const TextStyle(
                color: AppColors.error,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showCancelConfirm(BuildContext context, ParentLeaveRequestController controller) {
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
          contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM, vertical: AppConstants.paddingS),
        ),
        maxLines: 2,
      ),
    ).then((confirm) {
      if (confirm) {
        final reason = reasonController.text.trim();
        Get.back(); // Đóng bottom sheet chi tiết để làm mới data
        controller.cancelRequest(
          request.id ?? '', 
          reason.isEmpty ? AppStrings.leaveRequestAutoCancel : reason
        );
      }
    });
  }
}
