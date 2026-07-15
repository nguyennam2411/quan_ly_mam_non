import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/state/app_empty_state.dart';
import '../../../../global_widgets/state/app_loading.dart';
import '../controllers/teacher_talent_controller.dart';
import '../../../../data/models/talent_class_model.dart';
import '../../../../core/values/app_database.dart';

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
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showClassDetailBottomSheet(talentClass),
        borderRadius: BorderRadius.circular(12),
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
                      color: talentClass.status == AppDatabase.statusActive ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      talentClass.status == AppDatabase.statusActive ? 'Đang tuyển sinh' : 'Tạm ngừng',
                      style: TextStyle(
                        color: talentClass.status == AppDatabase.statusActive ? Colors.green : Colors.red,
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
                  Expanded(
                    child: Text(
                      talentClass.scheduleInfo,
                      style: const TextStyle(color: Colors.grey),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
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
                    Get.toNamed('/teacher/talent-attendance', arguments: talentClass);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary.withOpacity(0.1),
                    foregroundColor: AppColors.primary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Điểm danh lớp', style: TextStyle(fontWeight: FontWeight.bold)),
                ),
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
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.settings, color: AppColors.primary, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Quản lý lớp', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(
                          talentClass.name,
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.onSurface),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Divider(),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.fact_check_outlined, color: Colors.blue),
              ),
              title: const Text('Điểm danh lớp', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Ghi nhận có mặt/vắng mặt'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.back();
                Get.toNamed('/teacher/talent-attendance', arguments: talentClass);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.orange.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.people_alt_outlined, color: Colors.orange),
              ),
              title: const Text('Danh sách học sinh', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Xem danh sách đã đăng ký'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.back();
                Get.toNamed('/teacher/talent-students', arguments: talentClass);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: Colors.purple.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: const Icon(Icons.edit_note_outlined, color: Colors.purple),
              ),
              title: const Text('Chỉnh sửa thông tin', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Cập nhật lịch học, học phí...'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () {
                Get.back();
                _showEditClassBottomSheet(talentClass);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: talentClass.status == AppDatabase.statusActive ? Colors.red.withOpacity(0.1) : Colors.green.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Icon(talentClass.status == AppDatabase.statusActive ? Icons.block : Icons.check_circle_outline, color: talentClass.status == AppDatabase.statusActive ? Colors.red : Colors.green),
              ),
              title: Text(talentClass.status == AppDatabase.statusActive ? 'Ngừng chiêu sinh' : 'Mở lại chiêu sinh', style: TextStyle(fontWeight: FontWeight.bold, color: talentClass.status == AppDatabase.statusActive ? Colors.red : Colors.green)),
              subtitle: Text(talentClass.status == AppDatabase.statusActive ? 'Tạm khóa không nhận thêm hs' : 'Mở lại để nhận đăng ký mới'),
              onTap: () {
                Get.back();
                controller.toggleClassStatus(talentClass);
              },
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showEditClassBottomSheet(TalentClassModel talentClass) {
    final feeController = TextEditingController(text: talentClass.feePerMonth.toString());
    final descController = TextEditingController(text: talentClass.description ?? '');

    // Pre-populate data
    if (controller.availableSubjects.contains(talentClass.name)) {
      controller.selectedSubject.value = talentClass.name;
    } else {
      controller.selectedSubject.value = controller.availableSubjects.first;
    }
    
    controller.selectedDays.clear();
    controller.selectedTime.value = null;
    controller.selectedStartDate.value = null;
    controller.selectedEndDate.value = null;

    final scheduleStr = talentClass.scheduleInfo;
    
    // Parse time
    final timeMatch = RegExp(r'(\d{1,2}):(\d{2})').firstMatch(scheduleStr);
    if (timeMatch != null) {
      controller.selectedTime.value = TimeOfDay(
        hour: int.parse(timeMatch.group(1)!), 
        minute: int.parse(timeMatch.group(2)!)
      );
    }
    
    // Parse days
    final daysMapping = {'T2': 2, 'T3': 3, 'T4': 4, 'T5': 5, 'T6': 6, 'T7': 7, 'CN': 8};
    for (var entry in daysMapping.entries) {
      // Avoid matching 'T7' inside some other string by checking if it's there
      if (scheduleStr.contains(entry.key)) {
        controller.selectedDays.add(entry.value);
      }
    }
    controller.selectedDays.sort();
    
    // Parse dates
    try {
      final dateMatches = RegExp(r'(\d{2}/\d{2}/\d{4})').allMatches(scheduleStr).toList();
      if (dateMatches.isNotEmpty) {
        controller.selectedStartDate.value = DateFormat('dd/MM/yyyy').parse(dateMatches[0].group(1)!);
        if (dateMatches.length > 1) {
          controller.selectedEndDate.value = DateFormat('dd/MM/yyyy').parse(dateMatches[1].group(1)!);
        }
      }
    } catch (e) {
      // Ignore parse error
    }

    Get.bottomSheet(
      Container(
        padding: EdgeInsets.only(
          top: 24,
          left: 16,
          right: 16,
          bottom: Get.mediaQuery.viewInsets.bottom + 24, // adjust for keyboard
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Chỉnh sửa lớp học', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 24),
              Obx(() => DropdownButtonFormField<String>(
                value: controller.selectedSubject.value,
                decoration: const InputDecoration(
                  labelText: 'Môn năng khiếu',
                  border: OutlineInputBorder(),
                ),
                items: controller.availableSubjects.map((subject) {
                  return DropdownMenuItem(
                    value: subject,
                    child: Text(subject),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) controller.selectedSubject.value = val;
                },
              )),
              _buildWeeklySchedulePicker(controller),
              const SizedBox(height: 12),
              Obx(() => _buildDatePickerRow(
                    'Ngày bắt đầu:',
                    controller.selectedStartDate.value,
                    () => controller.pickDate(controller.selectedStartDate),
                  )),
              const SizedBox(height: 8),
              Obx(() => _buildDatePickerRow(
                    'Ngày kết thúc:',
                    controller.selectedEndDate.value,
                    () => controller.pickDate(controller.selectedEndDate),
                  )),
              const SizedBox(height: 16),
              TextField(
                controller: feeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Học phí mỗi tháng (VNĐ)',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Mô tả chi tiết',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    String scheduleText = '';
                    if (controller.selectedDays.isNotEmpty && controller.selectedTime.value != null) {
                      final daysString = controller.selectedDays.map((d) => d == 8 ? 'CN' : 'T$d').join(', ');
                      final timeString = '${controller.selectedTime.value!.hour.toString().padLeft(2, '0')}:${controller.selectedTime.value!.minute.toString().padLeft(2, '0')}';
                      scheduleText = '$daysString - $timeString';
                    }
                    String dateRangeText = '';

                    if (controller.selectedStartDate.value != null && controller.selectedEndDate.value != null) {
                      final start = DateFormat('dd/MM/yyyy').format(controller.selectedStartDate.value!);
                      final end = DateFormat('dd/MM/yyyy').format(controller.selectedEndDate.value!);
                      dateRangeText = 'Từ $start đến $end';
                    } else if (controller.selectedStartDate.value != null) {
                      dateRangeText = 'Từ ${DateFormat('dd/MM/yyyy').format(controller.selectedStartDate.value!)}';
                    }

                    if (scheduleText.isNotEmpty && dateRangeText.isNotEmpty) {
                      scheduleText = '$scheduleText ($dateRangeText)';
                    } else if (dateRangeText.isNotEmpty) {
                      scheduleText = dateRangeText;
                    } else if (scheduleText.isEmpty) {
                      scheduleText = 'Chưa xếp lịch';
                    }

                    final fee = int.tryParse(feeController.text.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
                    
                    // We need to pass the updated subject name as well. Since updateClassDetails 
                    // only takes fee, desc, schedule, let's update TeacherTalentController method too.
                    controller.updateClassDetails(talentClass.id!, fee, descController.text, scheduleText, controller.selectedSubject.value);
                    Get.back();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lưu thay đổi', style: TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
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
            Obx(() => DropdownButtonFormField<String>(
              value: controller.selectedSubject.value,
              decoration: const InputDecoration(
                labelText: 'Tên môn học năng khiếu',
                border: OutlineInputBorder(),
              ),
              items: controller.availableSubjects.map((subject) {
                return DropdownMenuItem(
                  value: subject,
                  child: Text(subject),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) controller.selectedSubject.value = val;
              },
            )),
            _buildWeeklySchedulePicker(controller),
            const SizedBox(height: 12),
            Obx(() => _buildDatePickerRow(
                  'Ngày bắt đầu:',
                  controller.selectedStartDate.value,
                  () => controller.pickDate(controller.selectedStartDate),
                )),
            const SizedBox(height: 8),
            Obx(() => _buildDatePickerRow(
                  'Ngày kết thúc:',
                  controller.selectedEndDate.value,
                  () => controller.pickDate(controller.selectedEndDate),
                )),
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
                  if (feeController.text.isEmpty) {
                    Get.snackbar('Lỗi', 'Vui lòng nhập đủ thông tin');
                    return;
                  }
                  String scheduleText = '';
                  if (controller.selectedDays.isNotEmpty && controller.selectedTime.value != null) {
                    final daysString = controller.selectedDays.map((d) => d == 8 ? 'CN' : 'T$d').join(', ');
                    final timeString = '${controller.selectedTime.value!.hour.toString().padLeft(2, '0')}:${controller.selectedTime.value!.minute.toString().padLeft(2, '0')}';
                    scheduleText = '$daysString - $timeString';
                  }
                  String dateRangeText = '';

                  if (controller.selectedStartDate.value != null && controller.selectedEndDate.value != null) {
                    final start = DateFormat('dd/MM/yyyy').format(controller.selectedStartDate.value!);
                    final end = DateFormat('dd/MM/yyyy').format(controller.selectedEndDate.value!);
                    dateRangeText = 'Từ $start đến $end';
                  } else if (controller.selectedStartDate.value != null) {
                    dateRangeText = 'Từ ' + DateFormat('dd/MM/yyyy').format(controller.selectedStartDate.value!);
                  }

                  if (scheduleText.isNotEmpty && dateRangeText.isNotEmpty) {
                    scheduleText = '$scheduleText ($dateRangeText)';
                  } else if (dateRangeText.isNotEmpty) {
                    scheduleText = dateRangeText;
                  } else if (scheduleText.isEmpty) {
                    scheduleText = 'Chưa xếp lịch';
                  }

                  final feeString = feeController.text.replaceAll(RegExp(r'[^0-9]'), '');

                  final newClass = TalentClassModel(
                    name: controller.selectedSubject.value,
                    scheduleInfo: scheduleText,
                    feePerMonth: int.tryParse(feeString) ?? 0,
                    status: AppDatabase.statusActive,
                  );
                  controller.createClass(newClass);
                  controller.selectedStartDate.value = null; // Reset
                  controller.selectedEndDate.value = null;
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

  Widget _buildDatePickerRow(String label, DateTime? date, VoidCallback onTap) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(width: 8),
        Expanded(
          child: Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.calendar_month, size: 18),
              label: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(date != null ? DateFormat('dd/MM/yyyy').format(date) : 'Chọn ngày giờ'),
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildWeeklySchedulePicker(TeacherTalentController controller) {
    final days = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Ngày học trong tuần:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(7, (index) {
            return Obx(() {
              final isSelected = controller.selectedDays.contains(index + 2); // 2 is Monday
              return InkWell(
                onTap: () => controller.toggleDay(index + 2),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary : Colors.grey[200],
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: isSelected ? AppColors.primary : Colors.grey[400]!),
                  ),
                  child: Text(
                    days[index],
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.grey[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            });
          }),
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Giờ học:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            Obx(() => TextButton.icon(
              onPressed: () => controller.pickTime(),
              icon: const Icon(Icons.access_time, size: 18),
              label: Text(
                controller.selectedTime.value != null
                    ? '${controller.selectedTime.value!.hour.toString().padLeft(2, '0')}:${controller.selectedTime.value!.minute.toString().padLeft(2, '0')}'
                    : 'Chọn giờ',
              ),
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            )),
          ],
        ),
      ],
    );
  }
}
