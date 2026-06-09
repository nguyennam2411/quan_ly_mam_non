import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../core/values/app_database.dart';
import '../../../../global_widgets/chips/status_badge.dart';
import '../../../../global_widgets/inputs/app_search_bar.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
import '../../../../global_widgets/medication_request/medication_request_detail_modal.dart';
import '../controllers/teacher_medication_request_controller.dart';

class TeacherMedicationRequestView extends GetView<TeacherMedicationRequestController> {
  const TeacherMedicationRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: const CircleBackButton(),
        title: const Text('Đơn dặn thuốc (Giáo viên)', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Filter section
          _buildFilterSection(),
          
          // List section
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              if (controller.filteredRequests.isEmpty) {
                return const Center(child: Text('Không có đơn dặn thuốc nào.'));
              }
              return ListView.separated(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                itemCount: controller.filteredRequests.length,
                separatorBuilder: (_, _) => const SizedBox(height: 16),
                itemBuilder: (context, index) {
                  final request = controller.filteredRequests[index];
                  return _buildRequestCard(context, request);
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      color: AppColors.surface,
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL, vertical: AppConstants.paddingM),
      child: Column(
        children: [
          // Search Bar
          AppSearchBar(
            hintText: 'Tìm học sinh...',
            onChanged: (val) => controller.searchQuery.value = val,
            backgroundColor: AppColors.surfaceContainerLowest,
          ),
          AppConstants.spacingM,
          // Segmented Control cho Trạng thái
          Obx(() => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
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
        ],
      ),
    );
  }

  Widget _buildStatusChip(String label) {
    final isSelected = controller.selectedStatus.value == label;
    final count = controller.statusCounts[label];

    return ChoiceChip(
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (count != null) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.all(2),
              constraints: const BoxConstraints(
                minWidth: 18,
                minHeight: 18,
              ),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.outlineVariant.withValues(alpha: 0.2),
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
        ],
      ),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) controller.selectedStatus.value = label;
      },
      selectedColor: AppColors.primary.withValues(alpha: 0.1),
      labelStyle: TextStyle(
        color: isSelected ? AppColors.primary : AppColors.onSurfaceVariant,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        side: BorderSide(
          color: isSelected ? AppColors.primary : AppColors.outlineVariant,
        ),
      ),
    );
  }

  Widget _buildRequestCard(BuildContext context, dynamic request) {
    final isPending = request.status == AppDatabase.pending;
    final student = request.student;

    return GestureDetector(
      onTap: () {
        MedicationRequestDetailModal.show(
          request: request,
          isTeacher: true,
          onTransferMedical: isPending ? () => controller.transferToMedical(request.id!) : null,
          onComplete: isPending ? () => controller.markAsCompleted(request.id!) : null,
        );
      },
      child: Container(
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
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(height: 1, thickness: 1),
            ),
            
            // Chi tiết ngắn gọn
            _buildInfoRow(Icons.medical_information, 'Ngày uống:', request.date),
            const SizedBox(height: 8),
            _buildInfoRow(Icons.medication_liquid_rounded, 'Tên thuốc:', request.medicineName),
            const SizedBox(height: 8),
            const Text(
              'Nhấn để xem chi tiết đơn thuốc',
              style: TextStyle(
                fontSize: 12,
                fontStyle: FontStyle.italic,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        SizedBox(
          width: 90,
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
}
