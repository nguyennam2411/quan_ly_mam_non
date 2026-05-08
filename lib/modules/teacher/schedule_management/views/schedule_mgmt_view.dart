import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_constants.dart';
import 'package:quan_ly_mam_non/global_widgets/calendar/app_calendar_picker.dart';
import 'package:quan_ly_mam_non/modules/teacher/schedule_management/controllers/schedule_mgmt_controller.dart';
import 'package:quan_ly_mam_non/modules/teacher/schedule_management/widgets/schedule_slot_card.dart';

import 'package:quan_ly_mam_non/global_widgets/headers/main_app_bar.dart';

class ScheduleMgmtView extends GetView<ScheduleMgmtController> {
  const ScheduleMgmtView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(title: 'Thời khóa biểu'),
      body: Column(
        children: [
          _buildCompactHeader(context),
          
          // Tiêu đề phụ
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Row(
              children: [
                const Text(
                  'Lịch trình chi tiết',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(child: Divider(color: Colors.grey.shade200)),
              ],
            ),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }
              
              if (controller.dailySchedule.isEmpty) {
                return _buildEmptyState();
              }

              return ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 40),
                itemCount: controller.dailySchedule.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final item = controller.dailySchedule[index];
                  
                  // Kiểm tra nếu đây là bài học bổ sung đầu tiên trong danh sách
                  bool showSupplementalHeader = false;
                  if (item.schedule == null) {
                    if (index == 0 || controller.dailySchedule[index - 1].schedule != null) {
                      showSupplementalHeader = true;
                    }
                  }

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showSupplementalHeader)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                          child: Row(
                            children: [
                              const Text(
                                'Bài soạn bổ sung',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(child: Divider(color: Colors.grey.shade200)),
                            ],
                          ),
                        ),
                      ScheduleSlotCard(
                        item: item,
                        onTap: () => controller.goToLessonEditor(item),
                      ),
                    ],
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildCompactHeader(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 15,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Dòng trên: Tháng & Icon Lịch
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 16, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Obx(() => Text(
                  DateFormat('MMMM yyyy', 'vi').format(controller.selectedDate.value),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.black87,
                  ),
                )),
                IconButton(
                  onPressed: () => _showCalendarDialog(context),
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 22),
                  ),
                ),
              ],
            ),
          ),
          
          // Dòng dưới: Thanh chọn 7 ngày trong tuần (Cố định)
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Obx(() {
              final selectedDate = controller.selectedDate.value;
              // Tính ngày đầu tuần (Thứ 2)
              final firstDayOfWeek = selectedDate.subtract(Duration(days: selectedDate.weekday - 1));
              
              return Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: List.generate(7, (index) {
                  final date = firstDayOfWeek.add(Duration(days: index));
                  final isSelected = date.day == selectedDate.day && 
                                   date.month == selectedDate.month &&
                                   date.year == selectedDate.year;
                  final dayName = _getShortDayName(date.weekday);

                  return GestureDetector(
                    onTap: () => controller.onDateChanged(date),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: (MediaQuery.of(context).size.width - 64) / 7,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? AppColors.primary : Colors.transparent,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: isSelected ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ] : null,
                      ),
                      child: Column(
                        children: [
                          Text(
                            dayName,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? Colors.white70 : Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            date.day.toString(),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }

  void _showCalendarDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.radiusL)),
        child: SizedBox(
          height: 450,
          child: AppCalendarPicker(
            controller: DateRangePickerController(),
            initialDate: controller.selectedDate.value,
            onSelectionChanged: (date) {
              controller.onDateChanged(date);
              Navigator.pop(context);
            },
          ),
        ),
      ),
    );
  }

  String _getShortDayName(int weekday) {
    switch (weekday) {
      case 1: return 'T2';
      case 2: return 'T3';
      case 3: return 'T4';
      case 4: return 'T5';
      case 5: return 'T6';
      case 6: return 'T7';
      case 7: return 'CN';
      default: return '';
    }
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today_rounded, size: 64, color: Colors.grey.shade200),
          const SizedBox(height: 16),
          Text(
            'Không có lịch học cho ngày này',
            style: TextStyle(color: Colors.grey.shade400, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
