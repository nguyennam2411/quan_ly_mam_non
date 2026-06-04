import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/headers/section_header.dart';
import '../../../../global_widgets/dialogs/app_loading.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../../../../global_widgets/calendar/app_calendar_picker.dart';
import '../controllers/meal_plan_controller.dart';

class MealPlanView extends GetView<MealPlanController> {
  const MealPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() => MainAppBar(title: controller.gradeName.value)),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCompactHeader(context),
          
          // Tiêu đề phụ
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: const SectionHeader(title: AppStrings.mealPlanDetailTitle),
          ),

          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const AppLoading();
              }

              if (controller.weeklyMenu.isEmpty) {
                return _buildEmptyState();
              }

              final menu = controller.currentDayMenu;
              if (menu == null) {
                return _buildEmptyState();
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(AppConstants.paddingL),
                child: Column(
                  children: [
                    _buildMealCard(
                      title: AppStrings.mealBreakfast,
                      time: menu.breakfastTime,
                      content: menu.breakfast,
                      images: menu.breakfastImg,
                      icon: Icons.wb_sunny_rounded,
                      color: AppColors.tertiaryContainer,
                      onColor: AppColors.onTertiaryContainer,
                    ),
                    AppConstants.spacingL,
                    _buildMealCard(
                      title: AppStrings.mealLunch,
                      time: menu.lunchTime,
                      content: menu.lunch,
                      images: menu.lunchImg,
                      icon: Icons.restaurant_rounded,
                      color: AppColors.primaryContainer,
                      onColor: AppColors.onPrimaryContainer,
                    ),
                    AppConstants.spacingL,
                    _buildMealCard(
                      title: AppStrings.mealSnack,
                      time: menu.snackTime,
                      content: menu.snack,
                      images: menu.snackImg,
                      icon: Icons.bakery_dining_rounded,
                      color: AppColors.secondaryContainer,
                      onColor: AppColors.onSecondaryContainer,
                    ),
                  ],
                ),
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
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.calendar_month_rounded, color: AppColors.primary, size: 22),
                  ),
                ),
              ],
            ),
          ),
          
          // Dòng dưới: Thanh chọn 7 ngày trong tuần
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
                            color: AppColors.primary.withValues(alpha: 0.3),
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

  Widget _buildMealCard({
    required String title,
    required String time,
    required String content,
    required List<String> images,
    required IconData icon,
    required Color color,
    required Color onColor,
  }) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias,
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
          // Header with Title & Time
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(AppConstants.radiusXL),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: onColor, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: onColor,
                  ),
                ),
                if (time.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Text(
                    '($time)',
                    style: TextStyle(
                      fontSize: 12,
                      color: onColor.withValues(alpha: 0.8),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Meal Content Text
          Padding(
            padding: const EdgeInsets.fromLTRB(AppConstants.paddingM, AppConstants.paddingM, AppConstants.paddingM, 8),
            child: Text(
              content.isEmpty ? AppStrings.mealNotUpdated : content,
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                fontWeight: FontWeight.w600,
                color: content.isEmpty ? AppColors.outline : AppColors.onSurface,
                fontStyle: content.isEmpty ? FontStyle.italic : FontStyle.normal,
              ),
            ),
          ),

          // Images Section
          if (images.isNotEmpty)
            Container(
              height: 160,
              margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingM),
                itemCount: images.length,
                separatorBuilder: (context, index) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  return Container(
                    width: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                      border: Border.all(color: AppColors.surfaceVariant.withValues(alpha: 0.5)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusL - 1),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: AppLoading(
                              size: 20,
                            ),
                          );
                        },
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: AppColors.surfaceContainerLow,
                          child: const Icon(Icons.broken_image_rounded, color: AppColors.outline),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          
          if (images.isEmpty && content.isNotEmpty)
            const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return const AppEmptyState(
      title: AppStrings.mealEmptyTitle,
      description: AppStrings.mealEmptyDesc,
      icon: Icons.restaurant_menu_rounded,
    );
  }
}
