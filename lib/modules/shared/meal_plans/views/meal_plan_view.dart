import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../global_widgets/buttons/circle_back_button.dart';
import '../controllers/meal_plan_controller.dart';

class MealPlanView extends GetView<MealPlanController> {
  const MealPlanView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: const CircleBackButton(),
        centerTitle: true,
        title: Obx(() => Text(
              controller.gradeName.value,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.onBackground,
                  ),
            )),
      ),
      body: Column(
        children: [
          _buildDaySelector(),
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
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
                      title: 'Bữa sáng',
                      time: menu.breakfastTime,
                      content: menu.breakfast,
                      images: menu.breakfastImg,
                      icon: Icons.wb_sunny_rounded,
                      color: AppColors.tertiaryContainer,
                      onColor: AppColors.onTertiaryContainer,
                    ),
                    AppConstants.spacingL,
                    _buildMealCard(
                      title: 'Bữa trưa',
                      time: menu.lunchTime,
                      content: menu.lunch,
                      images: menu.lunchImg,
                      icon: Icons.restaurant_rounded,
                      color: AppColors.primaryContainer,
                      onColor: AppColors.onPrimaryContainer,
                    ),
                    AppConstants.spacingL,
                    _buildMealCard(
                      title: 'Bữa xế',
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

  Widget _buildDaySelector() {
    final days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6'];
    return Container(
      height: 80,
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingL),
        itemCount: days.length,
        separatorBuilder: (context, index) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Obx(() {
            bool isSelected = controller.selectedDayIndex.value == index;
            return GestureDetector(
              onTap: () => controller.changeDay(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: 70,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primary : AppColors.surfaceVariant.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      days[index].split(' ')[0],
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? AppColors.onPrimary.withOpacity(0.8) : AppColors.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      days[index].split(' ')[1],
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? AppColors.onPrimary : AppColors.onSurface,
                      ),
                    ),
                  ],
                ),
              ),
            );
          });
        },
      ),
    );
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
            color: AppColors.onSurface.withOpacity(0.05),
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
                      color: onColor.withOpacity(0.8),
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
              content.isEmpty ? 'Chưa cập nhật thực đơn' : content,
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
                      border: Border.all(color: AppColors.surfaceVariant.withOpacity(0.5)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(AppConstants.radiusL - 1),
                      child: Image.network(
                        images[index],
                        fit: BoxFit.cover,
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              strokeWidth: 2,
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.restaurant_menu_rounded, size: 80, color: AppColors.outlineVariant),
          AppConstants.spacingM,
          Text(
            'Chưa có thực đơn tuần nầy',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Vui lòng quay lại sau',
            style: TextStyle(color: AppColors.outline),
          ),
        ],
      ),
    );
  }
}
