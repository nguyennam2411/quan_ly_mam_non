import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../../../../global_widgets/buttons/primary_button.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/values/user_role.dart';
import '../../../../data/models/event_model.dart';
import '../controllers/event_controller.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../global_widgets/images/custom_cached_image.dart';

class EventDetailView extends StatelessWidget {
  final EventModel event;
  final EventController controller;

  const EventDetailView({super.key, required this.event, required this.controller});

  @override
  Widget build(BuildContext context) {
    final isTeacher = UserRole.isTeacher(AuthService.to.userRole.value);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: MainAppBar(
        title: 'Chi tiết sự kiện',
        backgroundColor: Colors.white,
        titleColor: AppColors.onBackground,
        iconColor: AppColors.onBackground,
        actions: [
          if (isTeacher)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () {
                Get.defaultDialog(
                  title: 'Xóa sự kiện',
                  middleText: 'Hành động này không thể hoàn tác. Bạn có chắc chắn muốn xóa sự kiện này không?',
                  textConfirm: 'Xóa ngay',
                  textCancel: 'Hủy',
                  confirmTextColor: Colors.white,
                  buttonColor: Colors.red,
                  cancelTextColor: AppColors.primary,
                  onConfirm: () {
                    Get.back(); // close dialog
                    controller.deleteEvent(event.id!);
                  },
                );
              },
            )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Image or Gradient
            if (event.imageUrl != null && event.imageUrl!.isNotEmpty)
              CustomCachedImage(
                imageUrl: event.imageUrl!,
                width: double.infinity,
                height: 280,
                fit: BoxFit.cover,
                errorWidget: _buildFallbackHeader(),
              )
            else
              _buildFallbackHeader(),

            // Content Area
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                ),
                padding: const EdgeInsets.fromLTRB(24, 30, 24, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Status
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            event.title.toUpperCase(),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                          ),
                          child: Text(
                            event.status,
                            style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Section: Mô tả
                    const Text(
                      'Mô tả sự kiện',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onBackground),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Text(
                        event.description ?? 'Chưa có thông tin mô tả.',
                        style: const TextStyle(fontSize: 15, height: 1.6, color: AppColors.onSurfaceVariant),
                      ),
                    ),
                    if (event.documentUrl != null && event.documentUrl!.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            // Cần import 'package:url_launcher/url_launcher.dart';
                            final Uri url = Uri.parse(event.documentUrl!);
                            try {
                              await launchUrl(url, mode: LaunchMode.externalApplication);
                            } catch (e) {
                              Get.snackbar('Lỗi', 'Không thể mở tài liệu này');
                            }
                          },
                          icon: const Icon(Icons.picture_as_pdf_rounded, color: AppColors.primary),
                          label: const Text('Xem chi tiết đính kèm (PDF/Word)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.primary),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            backgroundColor: AppColors.primary.withOpacity(0.05),
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: 32),

                    // Section: Thông tin chung
                    const Text(
                      'Thông tin chi tiết',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.onBackground),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 15, offset: const Offset(0, 5)),
                        ],
                      ),
                      child: Column(
                        children: [
                          _buildInfoRow(Icons.location_on_rounded, 'Địa điểm', event.location),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.surfaceVariant)),
                          _buildInfoRow(
                            event.fee > 0 ? Icons.monetization_on_rounded : Icons.money_off_rounded, 
                            'Chi phí', 
                            event.fee > 0 ? NumberFormat.currency(locale: 'vi', symbol: 'đ').format(event.fee) : 'Miễn phí',
                            valueColor: event.fee > 0 ? AppColors.primary : Colors.green,
                          ),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.surfaceVariant)),
                          _buildInfoRow(Icons.calendar_month_rounded, 'Bắt đầu', DateFormat('dd/MM/yyyy • HH:mm').format(event.startDate)),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.surfaceVariant)),
                          _buildInfoRow(Icons.event_busy_rounded, 'Kết thúc', DateFormat('dd/MM/yyyy • HH:mm').format(event.endDate)),
                          const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Divider(height: 1, color: AppColors.surfaceVariant)),
                          _buildInfoRow(Icons.timer_outlined, 'Hạn đăng ký', DateFormat('dd/MM/yyyy • HH:mm').format(event.deadlineDate), isWarning: true),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -10)),
          ],
        ),
        child: SafeArea(
          child: _buildActionButtons(isTeacher),
        ),
      ),
    );
  }

  Widget _buildFallbackHeader() {
    return Container(
      width: double.infinity,
      height: 280,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.primary, AppColors.primaryContainer],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Icon(Icons.celebration_rounded, size: 80, color: Colors.white.withOpacity(0.5)),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isWarning = false, Color? valueColor}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isWarning ? Colors.red.withOpacity(0.1) : AppColors.primary.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 20, color: isWarning ? Colors.red : AppColors.primary),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: AppColors.outline, fontSize: 13, fontWeight: FontWeight.w600)),
              const SizedBox(height: 4),
              Text(
                value, 
                style: TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 15, 
                  color: valueColor ?? (isWarning ? Colors.red : AppColors.onSurface)
                )
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(bool isTeacher) {
    if (isTeacher) {
      return PrimaryButton(
        text: 'Xem danh sách đăng ký',
        onPressed: () => controller.showRegistrations(event),
        trailingIcon: Icons.people,
      );
    }

    return Obx(() {
      // Đọc observable variable để GetX theo dõi
      controller.registrations.length;
      final isPastDeadline = DateTime.now().isAfter(event.deadlineDate);
      
      final reg = controller.getRegistration(event.id!);
      
      if (reg != null) {
        final isRegistered = reg.status == AppDatabase.statusRegistered;
        final isPending = reg.status == AppDatabase.pending;
        
        Color bgColor = Colors.red.withOpacity(0.1);
        Color textColor = Colors.red;
        IconData iconData = Icons.cancel;
        String text = 'Đã từ chối tham gia';

        if (isRegistered) {
          bgColor = Colors.green.withOpacity(0.1);
          textColor = Colors.green;
          iconData = Icons.check_circle;
          text = 'Đã đăng ký tham gia';
        } else if (isPending) {
          bgColor = Colors.orange.withOpacity(0.1);
          textColor = Colors.orange;
          iconData = Icons.hourglass_top;
          text = 'Đang chờ xác nhận thanh toán';
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(12)),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(iconData, color: textColor),
              const SizedBox(width: 8),
              Text(text, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: textColor)),
            ],
          ),
        );
      }

      if (isPastDeadline) {
        return const Center(
          child: Text('Đã hết hạn đăng ký', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
        );
      }

      return Row(
        children: [
          Expanded(
            child: PrimaryButton(
              text: 'Tham gia',
              onPressed: () => controller.registerEvent(event, AppDatabase.statusRegistered, null),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: SizedBox(
              height: 50,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.grey),
                  padding: EdgeInsets.zero,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => controller.registerEvent(event, AppDatabase.statusDeclined, null),
                child: const Text('Không đi', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold, fontSize: 15)),
              ),
            ),
          ),
        ],
      );
    });
  }
}
