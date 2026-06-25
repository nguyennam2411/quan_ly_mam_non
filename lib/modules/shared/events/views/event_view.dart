import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/event_controller.dart';
import 'event_detail_view.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/values/user_role.dart';

class EventView extends GetView<EventController> {
  const EventView({super.key});

  @override
  Widget build(BuildContext context) {
    final isTeacher = UserRole.isTeacher(AuthService.to.userRole.value);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Sự kiện & Ngoại khóa', style: TextStyle(color: AppColors.onBackground, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: isTeacher ? FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => _showCreateEventDialog(context),
        child: const Icon(Icons.add, color: Colors.white),
      ) : null,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.events.isEmpty) {
          return const Center(child: Text('Chưa có sự kiện nào.'));
        }
        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: controller.events.length,
          itemBuilder: (context, index) {
            final event = controller.events[index];
            final reg = controller.getRegistration(event.id!);
            final isPastDeadline = DateTime.now().isAfter(event.deadlineDate);
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              child: InkWell(
                onTap: () => Get.to(() => EventDetailView(event: event, controller: controller)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
                      Image.network(
                        event.imageUrl!,
                        height: 140,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 140,
                          width: double.infinity,
                          color: Colors.grey[200],
                          child: const Icon(Icons.image_not_supported, color: Colors.grey, size: 50),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(child: Text(event.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary), maxLines: 1, overflow: TextOverflow.ellipsis)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                                child: Text(event.status, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(
                            event.fee > 0 ? Icons.monetization_on : Icons.money_off, 
                            event.fee > 0 ? 'Chi phí: ${NumberFormat.currency(locale: 'vi', symbol: 'đ').format(event.fee)}' : 'Sự kiện Miễn phí'
                          ),
                          const SizedBox(height: 4),
                          _buildInfoRow(Icons.location_on, 'Địa điểm: ${event.location}'),
                          const SizedBox(height: 4),
                          _buildInfoRow(Icons.access_time, 'Hạn đăng ký: ${DateFormat('dd/MM/yyyy HH:mm').format(event.deadlineDate)}'),
                          const SizedBox(height: 12),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text('Xem chi tiết', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                              Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.primary),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(color: Colors.grey[800], fontSize: 13))),
      ],
    );
  }

  void _showCreateEventDialog(BuildContext context) {
    final titleCtrl = TextEditingController();
    final descCtrl = TextEditingController();
    final locationCtrl = TextEditingController();
    final feeCtrl = TextEditingController();
    
    // Khởi tạo ngày mặc định vào state
    controller.selectedStartDate.value = DateTime.now().add(const Duration(days: 7));
    controller.selectedEndDate.value = DateTime.now().add(const Duration(days: 7, hours: 4));
    controller.selectedDeadlineDate.value = DateTime.now().add(const Duration(days: 5));

    Future<void> pickDate(Rx<DateTime?> targetDate) async {
      final picked = await showDatePicker(
        context: context,
        initialDate: targetDate.value ?? DateTime.now(),
        firstDate: DateTime.now(),
        lastDate: DateTime.now().add(const Duration(days: 365)),
      );
      if (picked != null) {
        final time = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.fromDateTime(targetDate.value ?? DateTime.now()),
        );
        if (time != null) {
          targetDate.value = DateTime(picked.year, picked.month, picked.day, time.hour, time.minute);
        }
      }
    }

    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Tạo sự kiện mới', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 16),
              
              // Upload Banner
              GestureDetector(
                onTap: () => controller.pickImage(),
                child: Obx(() => Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey[400]!, style: BorderStyle.solid),
                    image: controller.selectedImageFile.value != null 
                      ? DecorationImage(image: FileImage(controller.selectedImageFile.value!), fit: BoxFit.cover)
                      : null
                  ),
                  child: controller.selectedImageFile.value == null 
                    ? const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Thêm ảnh Banner', style: TextStyle(color: Colors.grey))
                        ],
                      )
                    : null,
                )),
              ),
              const SizedBox(height: 16),

              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Tên sự kiện', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, maxLines: 3, decoration: const InputDecoration(labelText: 'Mô tả chi tiết', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: locationCtrl, decoration: const InputDecoration(labelText: 'Địa điểm', border: OutlineInputBorder())),
              const SizedBox(height: 12),
              TextField(controller: feeCtrl, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Chi phí (VNĐ)', border: OutlineInputBorder())),
              const SizedBox(height: 16),
              
              // Đính kèm tệp
              Obx(() => OutlinedButton.icon(
                onPressed: () => controller.pickDocument(),
                icon: Icon(controller.selectedDocumentFile.value != null ? Icons.check_circle : Icons.attach_file, 
                           color: controller.selectedDocumentFile.value != null ? Colors.green : AppColors.primary),
                label: Text(
                  controller.selectedDocumentFile.value != null 
                    ? 'Đã chọn tệp đính kèm' 
                    : 'Đính kèm tệp chi tiết (PDF, Word...)',
                  style: TextStyle(color: controller.selectedDocumentFile.value != null ? Colors.green : AppColors.primary),
                ),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  side: BorderSide(color: controller.selectedDocumentFile.value != null ? Colors.green : AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              )),
              const SizedBox(height: 16),
              
              // Chọn thời gian
              Obx(() => _buildDatePickerRow('Bắt đầu', controller.selectedStartDate.value, () => pickDate(controller.selectedStartDate))),
              const SizedBox(height: 8),
              Obx(() => _buildDatePickerRow('Kết thúc', controller.selectedEndDate.value, () => pickDate(controller.selectedEndDate))),
              const SizedBox(height: 8),
              Obx(() => _buildDatePickerRow('Hạn đăng ký', controller.selectedDeadlineDate.value, () => pickDate(controller.selectedDeadlineDate))),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                  onPressed: () {
                    final feeText = feeCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');
                    final fee = int.tryParse(feeText) ?? 0;
                    if (titleCtrl.text.isNotEmpty && locationCtrl.text.isNotEmpty) {
                      controller.createEvent(titleCtrl.text, descCtrl.text, locationCtrl.text, fee);
                      Get.back(); // close bottom sheet
                    } else {
                      Get.snackbar('Lỗi', 'Vui lòng nhập đủ tên và địa điểm', backgroundColor: const Color(0xFFFA746F), colorText: Colors.white);
                    }
                  },
                  child: const Text('Tạo sự kiện', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
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
        TextButton.icon(
          onPressed: onTap,
          icon: const Icon(Icons.calendar_month, size: 18),
          label: Text(date != null ? DateFormat('dd/MM/yyyy HH:mm').format(date) : 'Chọn ngày giờ'),
          style: TextButton.styleFrom(foregroundColor: AppColors.primary),
        )
      ],
    );
  }
}
