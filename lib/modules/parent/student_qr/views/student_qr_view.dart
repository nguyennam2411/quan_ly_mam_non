import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../controllers/student_qr_controller.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';

class StudentQrView extends GetView<StudentQrController> {
  const StudentQrView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const MainAppBar(title: 'Mã QR của bé'),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final token = controller.qrToken.value;
        if (token == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: AppColors.error),
                const SizedBox(height: 16),
                const Text('Không thể tải mã QR'),
                TextButton(
                  onPressed: controller.refreshQr,
                  child: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(AppConstants.paddingL),
          child: Column(
            children: [
              const SizedBox(height: 20),
              // QR Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(AppConstants.paddingXL),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppConstants.radiusXL),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'MÃ ĐIỂM DANH',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: AppColors.onSurfaceVariant,
                      ),
                    ),
                    // Student Info
                    if (controller.student.value != null) ...[
                      Text(
                        controller.student.value!.name.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                          color: AppColors.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Info Row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.school_outlined, size: 16, color: AppColors.onSurfaceVariant.withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Text(
                            'Lớp: ${controller.student.value!.classroomName ?? "Chưa gán"}',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.onSurfaceVariant.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Icon(Icons.cake_outlined, size: 16, color: AppColors.onSurfaceVariant.withOpacity(0.6)),
                          const SizedBox(width: 4),
                          Text(
                            controller.student.value!.birthday != null 
                                ? DateFormat('dd/MM/yyyy').format(controller.student.value!.birthday!)
                                : '---',
                            style: TextStyle(
                              fontSize: 15,
                              color: AppColors.onSurfaceVariant.withOpacity(0.8),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                    const SizedBox(height: 32),
                    // QR Code
                    QrImageView(
                      data: token.code,
                      version: QrVersions.auto,
                      size: 240.0,
                      gapless: false,
                      eyeStyle: const QrEyeStyle(
                        eyeShape: QrEyeShape.square,
                        color: AppColors.primary,
                      ),
                      dataModuleStyle: const QrDataModuleStyle(
                        dataModuleShape: QrDataModuleShape.square,
                        color: AppColors.onBackground,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Dùng mã này để điểm danh khi đến trường',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.onSurfaceVariant.withOpacity(0.7),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
