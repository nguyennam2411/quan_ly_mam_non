import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
import '../../../../global_widgets/calendar/app_calendar_picker.dart';
import '../controllers/attendance_controller.dart';
import '../widgets/calendar_legend.dart';

class AttendanceMainView extends GetView<AttendanceController> {
  const AttendanceMainView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const CircleBackButton(),
        title: Text(
          AppStrings.attendanceTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        actions: [
          IconButton(
            onPressed: () => controller.goToStatistics(),
            icon: const Icon(Icons.bar_chart_rounded, color: AppColors.primary),
            tooltip: 'Thống kê',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.attendanceHeader,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.onBackground,
                    ),
              ),
              AppConstants.spacingXL,

              Text(
                AppStrings.attendanceTimeInfo,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.outline.withValues(alpha: 0.8),
                      letterSpacing: 1.2,
                    ),
              ),
              AppConstants.spacingS,

              // Card ngày hiện tại
              Container(
                padding: const EdgeInsets.all(AppConstants.paddingM),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.attendanceCurrentDate,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 4),
                        Obx(() {
                          // Format: Thứ Hai, 20/10/2023
                          String dateStr = DateFormat('EEEE, dd/MM/yyyy', 'vi').format(controller.selectedDate.value);
                          return Text(
                            dateStr,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          );
                        }),
                      ],
                    ),
                    InkWell(
                      onTap: () => _showDatePicker(context),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.calendar_today, color: AppColors.primary, size: 24),
                      ),
                    ),
                  ],
                ),
              ),

              // Circle graphic & class summary
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Concentric circles graphic
                      Container(
                        padding: const EdgeInsets.all(30),
                        decoration: BoxDecoration(
                          color: AppColors.primary.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(30),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Container(
                            padding: const EdgeInsets.all(24),
                            decoration: const BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.edit_calendar, size: 48, color: Colors.white),
                          ),
                        ),
                      ),
                      AppConstants.spacingL,
                      Text(
                        AppStrings.attendanceListTitle, // Using list title as sub-header
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                ),
              ),

              // Action Buttons
              Obx(() => PrimaryButton(
                text: AppStrings.attendanceStart,
                trailingIcon: Icons.chevron_right,
                onPressed: controller.canAttendance 
                    ? () => controller.goToAttendance()
                    : null,
              )),
              AppConstants.spacingM,
              
              SizedBox(
                width: double.infinity,
                height: AppConstants.buttonHeight,
                child: OutlinedButton.icon(
                  onPressed: controller.canViewHistory
                      ? () => controller.goToHistory()
                      : null,
                  icon: const Icon(Icons.history, size: 20),
                  label: Text(
                    AppStrings.attendanceHistory,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: AppConstants.buttonFontSize,
                        ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.outlineVariant),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                  ),
                ),
              ),
              AppConstants.spacingL,

              // Bottom Hint Text
              Center(
                child: Text(
                  AppStrings.attendanceFooterHint,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.outline.withValues(alpha: 0.8),
                      ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }

  void _showDatePicker(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
          ),
          backgroundColor: AppColors.surface,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 460, // Chiều cao cho phần lịch
                child: AppCalendarPicker(
                  controller: controller.calendarController,
                  initialDate: controller.selectedDate.value,
                  title: AppStrings.attendanceSelectDate,
                  onSelectionChanged: (date) {
                    controller.onDateSelected(date);
                    Get.back();
                  },
                  onMonthChanged: (month) => controller.onMonthChanged(month),
                  getEventColor: (date) {
                    final String dateKey = DateFormat('yyyy-MM-dd').format(date);
                    final bool? isFullAttendance = controller.monthlyStatus[dateKey];
                    if (isFullAttendance == null) return null;
                    return isFullAttendance ? AppColors.success : AppColors.error;
                  },
                ),
              ),
              const CalendarLegend(),
              AppConstants.spacingM,
            ],
          ),
        );
      },
    );
  }
}
