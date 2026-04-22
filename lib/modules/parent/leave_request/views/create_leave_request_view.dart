import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../controllers/parent_leave_request_controller.dart';

class CreateLeaveRequestView extends GetView<ParentLeaveRequestController> {
  const CreateLeaveRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() => PopScope(
      canPop: !controller.hasChanges.value, // Cho phép thoát nếu chưa có thay đổi
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        
        final shouldPop = await AppDialogs.showExitConfirm();
        if (shouldPop) {
          controller.resetForm(); // Reset form nếu chấp nhận thoát
          Get.back();
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          leading: const CircleBackButton(),
          title: Text(
            AppStrings.leaveRequestCreateTitle,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Thông tin học sinh
              _buildStudentInfo(),
              AppConstants.spacingL,
  
              // 2. Chọn ngày
              _buildSectionLabel(AppStrings.leaveRequestFormDate),
              AppConstants.spacingS,
              _buildDateSelector(context),
              AppConstants.spacingL,
  
              // 3. Lý do
              _buildSectionLabel(AppStrings.leaveRequestFormReason),
              AppConstants.spacingS,
              _buildReasonInput(),
              AppConstants.spacingL,
  
              // 4. Minh chứng
              _buildSectionLabel(AppStrings.leaveRequestFormEvidence),
              AppConstants.spacingS,
              _buildEvidencePicker(),
              AppConstants.spacingXXL,
  
              // 5. Nút gửi
              Obx(() => PrimaryButton(
                    text: AppStrings.leaveRequestFormSubmit,
                    isLoading: controller.isLoading.value,
                    onPressed: () async {
                      final confirm = await AppDialogs.showConfirm(
                        message: AppStrings.leaveRequestConfirmSubmit,
                        agreeText: AppStrings.leaveRequestFormSubmit,
                      );
                      if (confirm) {
                        controller.submitRequest();
                      }
                    },
                  )),
              AppConstants.spacingL,
            ],
          ),
        ),
      ),
    ));
  }

  Widget _buildStudentInfo() {
    final student = ParentStudentService.to.selectedStudent.value;
    if (student == null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
            backgroundImage: student.avatarUrl != null ? NetworkImage(student.avatarUrl!) : null,
            child: student.avatarUrl == null ? const Icon(Icons.person, color: AppColors.primary) : null,
          ),
          AppConstants.spacingM,
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                student.name,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              Text(
                '${AppStrings.classLabel} ${student.classroomName ?? AppStrings.noClassAssigned}',
                style: TextStyle(color: AppColors.onSurfaceVariant, fontSize: 14),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.bold,
        color: AppColors.onSurface,
      ),
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Obx(() {
      final hasDate = controller.startDate.value != null;
      String dateText = AppStrings.leaveRequestSelectDate;
      if (hasDate) {
        if (controller.endDate.value != null && controller.startDate.value != controller.endDate.value) {
          dateText = '${DateFormat('dd/MM/yyyy').format(controller.startDate.value!)} - ${DateFormat('dd/MM/yyyy').format(controller.endDate.value!)}';
        } else {
          dateText = DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(controller.startDate.value!);
        }
      }

      return InkWell(
        onTap: () => _showDateRangePicker(context),
        borderRadius: BorderRadius.circular(AppConstants.radiusM),
        child: Container(
          padding: const EdgeInsets.all(AppConstants.paddingM),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
          ),
          child: Row(
            children: [
              const Icon(Icons.calendar_month_outlined, color: AppColors.primary),
              AppConstants.spacingM,
              Expanded(
                child: Text(
                  dateText,
                  style: TextStyle(
                    color: hasDate ? AppColors.onSurface : AppColors.onSurfaceVariant,
                    fontWeight: hasDate ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.outline),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildReasonInput() {
    return TextField(
      controller: controller.reasonController,
      maxLines: 4,
      decoration: InputDecoration(
        hintText: AppStrings.leaveRequestFormReasonHint,
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: BorderSide(color: AppColors.outline.withValues(alpha: 0.5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
        contentPadding: const EdgeInsets.all(AppConstants.paddingM),
      ),
    );
  }

  Widget _buildEvidencePicker() {
    return Obx(() {
      final image = controller.selectedImage.value;
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (image != null) ...[
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  child: Image.file(
                    image,
                    width: double.infinity,
                    height: 180,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () => controller.selectedImage.value = null,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.close, color: Colors.white, size: 20),
                    ),
                  ),
                ),
              ],
            ),
            AppConstants.spacingM,
          ],
          InkWell(
            onTap: () => controller.pickImage(),
            borderRadius: BorderRadius.circular(AppConstants.radiusM),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: AppConstants.paddingM),
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  style: BorderStyle.solid,
                ),
              ),
              child: const Column(
                children: [
                  Icon(Icons.add_a_photo_outlined, color: AppColors.primary),
                  AppConstants.spacingXS,
                  Text(
                    AppStrings.leaveRequestPickImage,
                    style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    });
  }

  void _showDateRangePicker(BuildContext context) {
    Get.bottomSheet(
      Container(
        height: 450,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(AppConstants.radiusXL),
            topRight: Radius.circular(AppConstants.radiusXL),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
              decoration: BoxDecoration(
                color: AppColors.outlineVariant.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Text(
              AppStrings.leaveRequestSelectRange,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            AppConstants.spacingM,
            Expanded(
              child: SfDateRangePicker(
                minDate: DateTime.now(), // Không cho chọn ngày quá khứ
                onSelectionChanged: (DateRangePickerSelectionChangedArgs args) {
                  if (args.value is PickerDateRange) {
                    controller.startDate.value = args.value.startDate;
                    controller.endDate.value = args.value.endDate ?? args.value.startDate;
                  }
                },
                selectionMode: DateRangePickerSelectionMode.range,
                initialSelectedRange: PickerDateRange(
                  controller.startDate.value ?? DateTime.now(),
                  controller.endDate.value ?? (controller.startDate.value ?? DateTime.now()),
                ),
                headerStyle: const DateRangePickerHeaderStyle(
                  textAlign: TextAlign.center,
                  textStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                monthCellStyle: const DateRangePickerMonthCellStyle(
                  todayTextStyle: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold),
                ),
                selectionColor: AppColors.primary,
                startRangeSelectionColor: AppColors.primary,
                endRangeSelectionColor: AppColors.primary,
                rangeSelectionColor: AppColors.primary.withValues(alpha: 0.1),
                todayHighlightColor: AppColors.primary,
              ),
            ),
            AppConstants.spacingM,
            PrimaryButton(
              text: AppStrings.confirmLabel,
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
