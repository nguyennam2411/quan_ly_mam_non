import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../routes/app_routes.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../../../../global_widgets/chips/status_badge.dart';
import '../controllers/parent_medication_request_controller.dart';
import '../../../../data/models/medication_request_model.dart';

class ParentMedicationRequestView extends GetView<ParentMedicationRequestController> {
  const ParentMedicationRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.transparent,
        elevation: 0,
        leading: const CircleBackButton(),
        title: Text(
          'Lịch sử Dặn Thuốc',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          _buildFilterAndSort(context),
          AppConstants.spacingM,
          Expanded(child: _buildRequestList(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed(Routes.PARENT_CREATE_MEDICATION_REQUEST);
        },
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add, color: AppColors.onPrimary),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.horizontalPadding,
        AppConstants.paddingL,
        AppConstants.horizontalPadding,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lịch sử Dặn Thuốc',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: AppColors.onBackground,
            ),
          ),
          AppConstants.spacingXS,
          Text(
            'Xem lại các đơn dặn thuốc đã gửi cho giáo viên',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.onSurfaceVariant,
            ),
          ),
          AppConstants.spacingL,
        ],
      ),
    );
  }

  Widget _buildFilterAndSort(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: Obx(() => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildStatusChip(AppStrings.leaveStatusAll),
                    const SizedBox(width: 8),
                    _buildStatusChip(AppStrings.medicationStatusPending),
                    const SizedBox(width: 8),
                    _buildStatusChip(AppStrings.medicationStatusCompleted),
                    const SizedBox(width: 8),
                    _buildStatusChip(AppStrings.medicationStatusMedical),
                  ],
                ),
              )),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
              child: VerticalDivider(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                thickness: 1,
              ),
            ),
            _buildSortButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String label) {
    final isSelected = controller.selectedStatus.value == label;
    final activeColor = AppColors.primary;

    return InkWell(
      onTap: () => controller.selectedStatus.value = label,
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
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : AppColors.onBackground.withValues(alpha: 0.7),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            fontSize: 13,
          ),
        ),
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
        return const Center(child: CircularProgressIndicator());
      }

      final requests = controller.filteredRequests;

      if (requests.isEmpty) {
        return const AppEmptyState(
          title: 'Không có đơn thuốc nào',
          description: 'Chưa có lịch sử dặn thuốc nào được tìm thấy.',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.horizontalPadding),
        itemCount: requests.length,
        itemBuilder: (context, index) {
          final request = requests[index];
          return _buildMedicationCard(context, request);
        },
      );
    });
  }

  Widget _buildMedicationCard(BuildContext context, MedicationRequestModel request) {
    final student = request.student;
    final isPending = request.status == AppDatabase.pending;
    
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Avatar, Name, Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.2),
                backgroundImage: student?.avatarUrl != null ? NetworkImage(student!.avatarUrl!) : null,
                child: student?.avatarUrl == null ? Icon(Icons.person, color: AppColors.primary) : null,
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
                        'Đã gửi lúc: ${DateFormat('HH:mm - dd/MM/yyyy').format(request.createdAt!)}',
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
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(height: 1, thickness: 1),
          ),
          
          // Chi tiết đơn dặn thuốc
          Row(
            children: [
              Icon(Icons.medical_information, size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'Uống ngày: ${request.date}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          _buildDetailRow(Icons.medication_liquid_rounded, 'Tên thuốc:', request.medicineName),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.scale, 'Liều lượng:', request.dosage),
          const SizedBox(height: 8),
          _buildDetailRow(Icons.access_time, 'Giờ uống:', request.time),
          
          if (request.note != null && request.note!.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildDetailRow(Icons.notes, 'Ghi chú:', request.note!),
          ],
          
          if (request.prescriptionImage != null) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusM),
              child: Image.network(
                request.prescriptionImage!,
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 100,
                  width: double.infinity,
                  color: AppColors.surfaceContainerHigh,
                  child: const Icon(Icons.broken_image, color: AppColors.outline),
                ),
              ),
            ),
          ],
          
          // Action button (Huỷ đơn)
          if (isPending) ...[
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () => _showCancelConfirm(context, request.id!),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.8),
                  foregroundColor: AppColors.onPrimaryContainer,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusMax),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL, vertical: 0),
                  minimumSize: const Size(0, AppConstants.inputMinHeight),
                ),
                child: const Text(
                  AppStrings.leaveRequestCancel,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ],
      ),
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

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
          ),
        ),
      ],
    );
  }

  void _showCancelConfirm(BuildContext context, String requestId) {
    final reasonController = TextEditingController();
    
    AppDialogs.showConfirm(
      message: 'Bạn có chắc chắn muốn hủy đơn dặn thuốc này?',
      agreeText: 'Đồng ý',
      agreeColor: AppColors.error,
      customContent: TextField(
        controller: reasonController,
        decoration: InputDecoration(
          hintText: 'Nhập lý do hủy (không bắt buộc)',
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
