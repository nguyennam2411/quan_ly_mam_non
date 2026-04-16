import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_strings.dart';
import 'package:quan_ly_mam_non/core/values/app_assets.dart';
import 'package:quan_ly_mam_non/core/values/app_constants.dart';
import '../controllers/main_controller.dart';
import '../../notifications/controllers/notification_controller.dart';

// --- Model dữ liệu cho mỗi Tab ---
class _NavItemData {
  final String outlinedIcon;
  final String filledIcon;
  final String label;

  const _NavItemData({
    required this.outlinedIcon,
    required this.filledIcon,
    required this.label,
  });
}

// --- Danh sách dữ liệu Tab - chỉ cần sửa ở ĐÂY khi có thay đổi ---
const List<_NavItemData> _navItems = [
  _NavItemData(
    outlinedIcon: AppAssets.icHomeOutlined,
    filledIcon: AppAssets.icHomeFilled,
    label: AppStrings.tabHome,
  ),
  _NavItemData(
    outlinedIcon: AppAssets.icChatOutlined,
    filledIcon: AppAssets.icChatFilled,
    label: AppStrings.tabMessage,
  ),
  _NavItemData(
    outlinedIcon: AppAssets.icNotificationOutlined,
    filledIcon: AppAssets.icNotificationFilled,
    label: AppStrings.tabNotification,
  ),
  _NavItemData(
    outlinedIcon: AppAssets.icPersonOutlined,
    filledIcon: AppAssets.icPersonFilled,
    label: AppStrings.tabProfile,
  ),
];

class MainView extends GetView<MainController> {
  const MainView({super.key});

  // --- Factory Method: tạo icon SVG với màu cụ thể ---
  static Widget _buildSvgIcon(String assetPath, Color color) {
    return SvgPicture.asset(
      assetPath,
      width: AppConstants.navIconSize,
      height: AppConstants.navIconSize,
      colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
    );
  }

  // --- Factory Method: tạo BottomNavigationBarItem từ model dữ liệu ---
  BottomNavigationBarItem _buildNavItem(int index, _NavItemData data) {
    final notificationController = Get.find<NotificationController>();

    return BottomNavigationBarItem(
      icon: Obx(() {
        final icon = _buildSvgIcon(
          controller.currentIndex.value == index ? data.filledIcon : data.outlinedIcon, 
          controller.currentIndex.value == index ? AppColors.primary : AppColors.outline
        );

        // Chỉ hiện badge cho Tab Thông báo (Index 2)
        if (index == 2 && notificationController.unreadCount > 0) {
          return Badge(
            label: Text(notificationController.unreadCount.toString()),
            backgroundColor: AppColors.error,
            child: icon,
          );
        }
        return icon;
      }),
      label: data.label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
        index: controller.currentIndex.value,
        children: controller.pages,
      )),

      bottomNavigationBar: Obx(() => BottomNavigationBar(
        currentIndex: controller.currentIndex.value,
        onTap: controller.changePage,
        type: BottomNavigationBarType.fixed,
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.outline,
        selectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.bold, 
          fontSize: AppConstants.navFontSize
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.normal, 
          fontSize: AppConstants.navFontSize
        ),
        elevation: AppConstants.navElevation,
        items: List<BottomNavigationBarItem>.generate(_navItems.length, (index) => _buildNavItem(index, _navItems[index])),
      )),
    );
  }
}