import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../../../../global_widgets/state/app_loading.dart';
import '../controllers/parent_talent_controller.dart';
import '../../../../data/models/talent_class_model.dart';

class ParentTalentView extends GetView<ParentTalentController> {
  const ParentTalentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Đăng Ký Năng Khiếu',
        backgroundColor: AppColors.primary,
        titleColor: Colors.white,
        iconColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoading();
        }

        if (controller.availableClasses.isEmpty) {
          return const AppEmptyState(
            title: 'Chưa có lớp năng khiếu',
            description: 'Hiện chưa có lớp năng khiếu nào được đăng ký.',
            icon: Icons.star_border_rounded,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.availableClasses.length,
          itemBuilder: (context, index) {
            final talentClass = controller.availableClasses[index];
            return _buildClassCard(talentClass);
          },
        );
      }),
    );
  }

  Widget _buildClassCard(TalentClassModel talentClass) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => _showClassDetailBottomSheet(talentClass),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.star, color: AppColors.primary, size: 28),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          talentClass.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onSurface,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          talentClass.scheduleInfo,
                          style: const TextStyle(color: Colors.grey, fontSize: 14),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Học phí', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        '${talentClass.feePerMonth} đ/tháng',
                        style: const TextStyle(
                          color: AppColors.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  Obx(() {
                    final isEnrolled = controller.isEnrolled(talentClass.id!);
                    return ElevatedButton(
                      onPressed: () {
                        if (isEnrolled) {
                          _showCancelDialog(talentClass);
                        } else {
                          _showEnrollDialog(talentClass);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isEnrolled ? Colors.red.withOpacity(0.1) : AppColors.primary,
                        foregroundColor: isEnrolled ? Colors.red : Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: Text(
                        isEnrolled ? 'Hủy đăng ký' : 'Đăng ký học',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showClassDetailBottomSheet(TalentClassModel talentClass) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.star, color: AppColors.primary, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    talentClass.name,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            _buildDetailRow(Icons.calendar_month, 'Lịch học', talentClass.scheduleInfo),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.monetization_on_outlined, 'Học phí', '${talentClass.feePerMonth} đ/tháng'),
            const SizedBox(height: 16),
            _buildDetailRow(Icons.info_outline, 'Mô tả', talentClass.description ?? 'Chưa có thông tin mô tả chi tiết cho môn học này.'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Get.back(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Đóng', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: Colors.grey, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 13, fontWeight: FontWeight.w500)),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(color: AppColors.onSurface, fontSize: 15, height: 1.4),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showEnrollDialog(TalentClassModel talentClass) {
    Get.defaultDialog(
      title: 'Xác nhận đăng ký',
      content: Text('Bạn có muốn đăng ký lớp ${talentClass.name} cho bé với học phí ${talentClass.feePerMonth}đ/tháng?\n\nSố tiền này sẽ được tự động cộng vào hóa đơn tháng của bé.'),
      textConfirm: 'Xác nhận',
      textCancel: 'Đóng',
      confirmTextColor: Colors.white,
      buttonColor: AppColors.primary,
      onConfirm: () {
        Get.back();
        controller.enrollInClass(talentClass);
      },
    );
  }

  void _showCancelDialog(TalentClassModel talentClass) {
    Get.defaultDialog(
      title: 'Hủy đăng ký',
      content: Text('Bạn có chắc chắn muốn hủy đăng ký lớp ${talentClass.name}? Học phí sẽ được khấu trừ lại tự động.'),
      textConfirm: 'Đồng ý Hủy',
      textCancel: 'Giữ lại',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      cancelTextColor: Colors.grey,
      onConfirm: () {
        Get.back();
        controller.cancelEnrollment(talentClass);
      },
    );
  }
}
