import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_constants.dart';
import '../../core/values/app_database.dart';
import '../../core/values/app_strings.dart';
import '../../core/utils/dialog.dart';
import '../../data/models/medication_request_model.dart';
import '../dialogs/app_image_viewer.dart';
import '../chips/status_badge.dart';

class MedicationRequestDetailModal extends StatelessWidget {
  final MedicationRequestModel request;
  final bool isTeacher;
  final VoidCallback? onCancel;
  final VoidCallback? onTransferMedical;
  final VoidCallback? onComplete;

  const MedicationRequestDetailModal({
    super.key,
    required this.request,
    this.isTeacher = false,
    this.onCancel,
    this.onTransferMedical,
    this.onComplete,
  });

  static void show({
    required MedicationRequestModel request,
    bool isTeacher = false,
    VoidCallback? onCancel,
    VoidCallback? onTransferMedical,
    VoidCallback? onComplete,
  }) {
    Get.bottomSheet(
      MedicationRequestDetailModal(
        request: request,
        isTeacher: isTeacher,
        onCancel: onCancel,
        onTransferMedical: onTransferMedical,
        onComplete: onComplete,
      ),
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
                'Chi tiết Dặn Thuốc',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            AppConstants.spacingL,

            _buildContent(context),
            AppConstants.spacingXXL,

            // Actions
            _buildActions(context),
            AppConstants.spacingM,
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final student = request.student;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Student Info & Status
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.2),
              backgroundImage: student?.avatarUrl != null ? NetworkImage(student!.avatarUrl!) : null,
              child: student?.avatarUrl == null ? const Icon(Icons.person, color: AppColors.primary) : null,
            ),
            const SizedBox(width: AppConstants.paddingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          student?.name ?? 'Trẻ',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      _buildStatusBadge(request.status),
                    ],
                  ),
                  AppConstants.spacingXXS,
                  if (request.createdAt != null)
                    Text(
                      'Đã gửi lúc: ${DateFormat('HH:mm - dd/MM/yyyy').format(request.createdAt!.toLocal())}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.outline,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
        
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 16),
          child: Divider(height: 1, thickness: 1),
        ),
        
        // Medication Details
        Row(
          children: [
            const Icon(Icons.medical_information, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Uống ngày: ${request.date}',
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary, fontSize: 16),
            ),
          ],
        ),
        const SizedBox(height: 16),
        
        _buildDetailRow(Icons.medication_liquid_rounded, 'Tên thuốc:', request.medicineName),
        const SizedBox(height: 12),
        _buildDetailRow(Icons.scale, 'Liều lượng:', request.dosage),
        const SizedBox(height: 12),
        _buildDetailRow(Icons.access_time, 'Giờ uống:', request.time),
        
        if (request.note != null && request.note!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _buildDetailRow(Icons.notes, 'Ghi chú:', request.note!),
        ],
        
        if (request.prescriptionImage != null) ...[
          const SizedBox(height: 16),
          const Text('Ảnh đơn thuốc/Đơn thuốc mẫu:', style: TextStyle(fontWeight: FontWeight.w600, color: AppColors.onSurfaceVariant)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: () => AppImageViewer.show(imageUrls: [request.prescriptionImage!]),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: Image.network(
                request.prescriptionImage!,
                height: 150,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150,
                  width: double.infinity,
                  color: AppColors.surfaceContainerHigh,
                  child: const Icon(Icons.broken_image, color: AppColors.outline),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 15),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge(String status) {
    Color color;
    String text;
    
    switch (status) {
      case AppDatabase.pending:
        color = AppColors.warning;
        text = AppStrings.medicationStatusPending;
        break;
      case AppDatabase.approved:
      case AppDatabase.completed:
        color = AppColors.success;
        text = AppStrings.medicationStatusCompleted;
        break;
      case AppDatabase.rejected:
        color = AppColors.error;
        text = AppStrings.medicationStatusMedical;
        break;
      case AppDatabase.cancelled:
        color = AppColors.outline;
        text = AppStrings.leaveStatusCancelled;
        break;
      default:
        color = AppColors.outline;
        text = status;
        break;
    }

    return StatusBadge(
      text: text.toUpperCase(),
      color: color,
    );
  }

  Widget _buildActions(BuildContext context) {
    final bool isPending = request.status == AppDatabase.pending;

    return Column(
      children: [
        if (isPending) ...[
          if (!isTeacher && onCancel != null)
            SizedBox(
              width: double.infinity,
              height: AppConstants.buttonHeight,
              child: OutlinedButton(
                onPressed: () {
                  Get.back(); // close modal
                  onCancel!();
                },
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.error,
                  side: const BorderSide(color: AppColors.error),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  ),
                ),
                child: const Text('Hủy yêu cầu', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
            
          if (isTeacher)
            Row(
              children: [
                if (onTransferMedical != null)
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        _confirmAction(
                          context,
                          title: 'Bạn có chắc chắn muốn chuyển trường hợp này xuống Y tế?',
                          isWarning: true,
                          onConfirm: onTransferMedical!,
                        );
                      },
                      icon: const Icon(Icons.local_hospital_rounded, size: 18),
                      label: const Text('Chuyển Y tế', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red.shade400,
                        side: BorderSide(color: Colors.red.shade400),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        ),
                      ),
                    ),
                  ),
                if (onTransferMedical != null && onComplete != null)
                  const SizedBox(width: 12),
                if (onComplete != null)
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        _confirmAction(
                          context,
                          title: 'Xác nhận đã cho bé uống thuốc thành công?',
                          onConfirm: onComplete!,
                        );
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Đã Cho Uống', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.success,
                        foregroundColor: AppColors.onPrimary,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusL),
                        ),
                      ),
                    ),
                  ),
              ],
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
              'Đóng',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  void _confirmAction(BuildContext context, {required String title, required VoidCallback onConfirm, bool isWarning = false}) {
    AppDialogs.showConfirm(
      title: AppStrings.dialogConfirmTitle,
      message: title,
      agreeText: AppStrings.dialogAgree,
      agreeColor: isWarning ? AppColors.error : AppColors.primary,
      icon: isWarning ? Icons.warning_amber_rounded : Icons.check_circle_outline,
      iconColor: isWarning ? AppColors.error : AppColors.primary,
    ).then((confirm) {
      if (confirm) {
        Get.back(); // Đóng modal
        onConfirm();
      }
    });
  }
}
