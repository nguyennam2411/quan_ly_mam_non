import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../core/values/app_database.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
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
          TextField(
            onChanged: (val) => controller.searchQuery.value = val,
            decoration: InputDecoration(
              hintText: 'Tìm học sinh...',
              prefixIcon: const Icon(Icons.search, color: AppColors.outline),
              filled: true,
              fillColor: AppColors.surfaceContainerLowest,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
            ),
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
    return ChoiceChip(
      label: Text(label),
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
    final isMedical = request.status == AppDatabase.rejected;

    Color badgeColor = isPending ? Colors.orange : (isMedical ? Colors.red : Colors.green);
    String badgeText = isPending ? AppStrings.medicationStatusPending : (isMedical ? AppStrings.medicationStatusMedical : AppStrings.medicationStatusCompleted);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(AppConstants.paddingL),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Tiêu đề: Tên bé và Trạng thái
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                request.student?.name ?? 'Trẻ',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Text(
                  badgeText,
                  style: TextStyle(
                    color: badgeColor,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 24),
          
          // Chi tiết thuốc
          _buildInfoRow(Icons.medical_information, 'Tên thuốc:', request.medicineName),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.scale, 'Liều lượng:', request.dosage),
          const SizedBox(height: 8),
          _buildInfoRow(Icons.access_time, 'Giờ uống:', request.time),
          
          if (request.note != null && request.note.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildInfoRow(Icons.notes, 'Ghi chú:', request.note),
          ],
          
          if (request.prescriptionImage != null) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {
                // Có thể show Fullscreen image ở đây
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Image.network(
                  request.prescriptionImage ?? '',
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            )
          ],

          // Nút thao tác nếu chưa uống
          if (isPending) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.transferToMedical(request.id!),
                    icon: const Icon(Icons.local_hospital_rounded, color: Colors.white, size: 18),
                    label: const Text('Chuyển Y tế', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red.shade400,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.markAsCompleted(request.id!),
                    icon: const Icon(Icons.check_circle_outline, color: Colors.white, size: 18),
                    label: const Text('Đã Cho Uống', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusM)),
                    ),
                  ),
                ),
              ],
            )
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: AppColors.onSurfaceVariant),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14),
          ),
        ),
      ],
    );
  }
}
