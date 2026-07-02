import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../../../../global_widgets/state/app_loading.dart';
import '../controllers/teacher_talent_controller.dart';
import '../../../../data/models/talent_class_model.dart';

class TeacherTalentView extends GetView<TeacherTalentController> {
  const TeacherTalentView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MainAppBar(
        title: 'Quản lý Lớp Năng Khiếu',
        backgroundColor: AppColors.primary,
        titleColor: Colors.white,
        iconColor: Colors.white,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const AppLoading();
        }

        if (controller.talentClasses.isEmpty) {
          return const AppEmptyState(
            title: 'Chưa có lớp năng khiếu nào',
            description: 'Tạo lớp học năng khiếu mới bằng cách ấn nút Thêm bên dưới.',
            icon: Icons.star_border_rounded,
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.talentClasses.length,
          itemBuilder: (context, index) {
            final talentClass = controller.talentClasses[index];
            return _buildClassCard(talentClass);
          },
        );
      }),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateClassModal(context),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Tạo lớp', style: TextStyle(color: Colors.white)),
      ),
    );
  }

  Widget _buildClassCard(TalentClassModel talentClass) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    talentClass.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.onSurface,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: talentClass.isActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    talentClass.isActive ? 'Đang tuyển sinh' : 'Tạm ngừng',
                    style: TextStyle(
                      color: talentClass.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(talentClass.scheduleInfo, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.attach_money, size: 16, color: Colors.grey),
                const SizedBox(width: 4),
                Text(
                  '${talentClass.feePerMonth} đ/tháng',
                  style: const TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.snackbar('Thông báo', 'Chức năng điểm danh đang được cập nhật');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary.withOpacity(0.1),
                  foregroundColor: AppColors.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Điểm danh lớp'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateClassModal(BuildContext context) {
    final nameController = TextEditingController();
    final feeController = TextEditingController();
    final scheduleController = TextEditingController();

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tạo Lớp Năng Khiếu Mới',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Tên môn học (VD: Vẽ sáng tạo)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: scheduleController,
              decoration: const InputDecoration(
                labelText: 'Lịch học (VD: Thứ 3, 5 - 17:00)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: feeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Học phí mỗi tháng (VNĐ)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  if (nameController.text.isEmpty || feeController.text.isEmpty) {
                    Get.snackbar('Lỗi', 'Vui lòng nhập đủ thông tin');
                    return;
                  }
                  final newClass = TalentClassModel(
                    name: nameController.text,
                    scheduleInfo: scheduleController.text,
                    feePerMonth: int.tryParse(feeController.text) ?? 0,
                    isActive: true,
                  );
                  controller.createClass(newClass);
                  Get.back(); // Close bottom sheet
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Tạo Lớp', style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
