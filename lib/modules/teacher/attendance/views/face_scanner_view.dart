import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:camera/camera.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/core/values/app_constants.dart';
import 'package:quan_ly_mam_non/core/values/app_strings.dart';
import 'package:quan_ly_mam_non/global_widgets/headers/main_app_bar.dart';
import 'package:quan_ly_mam_non/global_widgets/state/app_loading.dart';
import '../controllers/face_scanner_controller.dart';

class FaceScannerView extends GetView<FaceScannerController> {
  const FaceScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: MainAppBar(
        title: controller.mode == 'register'
            ? 'Đăng ký khuôn mặt'
            : 'Điểm danh khuôn mặt',
        actions: [
          // Nút đổi camera
          Obx(() {
            final state = controller.scanState.value;
            if (state == FaceScanState.initializing ||
                state == FaceScanState.analyzing ||
                state == FaceScanState.success) {
              return const SizedBox.shrink();
            }
            return IconButton(
              onPressed: () => controller.switchCamera(),
              icon: const Icon(Icons.flip_camera_ios_rounded, color: AppColors.primary),
              tooltip: 'Đổi camera',
            );
          }),
          const SizedBox(width: 8),
        ],
      ),
      body: Stack(
        children: [
          // 1. Camera Feed Preview
          Obx(() {
            final state = controller.scanState.value;
            if (state == FaceScanState.initializing ||
                controller.cameraController == null ||
                !controller.cameraController!.value.isInitialized) {
              return const Center(child: AppLoading());
            }

            // Lock ratio
            final size = MediaQuery.of(context).size;
            final deviceRatio = size.width / size.height;
            final cameraRatio = controller.cameraController!.value.aspectRatio;

            // Vì thiết bị ở chế độ Portrait (dọc), tỉ lệ của camera preview hiển thị thực tế sẽ ngược lại (1 / cameraRatio)
            final portraitCameraRatio = 1 / cameraRatio;

            // Tính toán tỷ lệ scale phủ kín màn hình (chỉ zoom nhẹ khoảng ~1.1x đến 1.2x thay vì bị phóng đại 3.5x)
            final scale = portraitCameraRatio > deviceRatio
                ? portraitCameraRatio / deviceRatio
                : deviceRatio / portraitCameraRatio;

            return Transform.scale(
              scale: scale,
              child: Center(
                child: CameraPreview(controller.cameraController!),
              ),
            );
          }),

          // 2. Dark Overlay with Oval Cutout
          Obx(() {
            return CustomPaint(
              painter: _FaceScanOverlayPainter(state: controller.scanState.value),
              child: const SizedBox.expand(),
            );
          }),

          // 3. Status Message Overlay (Dòng chữ hướng dẫn)
          _buildStatusMessage(),

          // 4. Processing overlay
          Obx(() {
            final state = controller.scanState.value;
            if (state == FaceScanState.analyzing) {
              return _buildAnalyzingOverlay();
            }
            if (state == FaceScanState.success) {
              return _buildSuccessOverlay();
            }
            if (state == FaceScanState.error) {
              return _buildErrorOverlay();
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _buildStatusMessage() {
    return Positioned(
      bottom: 120,
      left: 24,
      right: 24,
      child: Obx(() {
        final state = controller.scanState.value;
        if (state == FaceScanState.analyzing ||
            state == FaceScanState.success ||
            state == FaceScanState.error) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.65),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Text(
            controller.statusMessage.value,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildAnalyzingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Biểu tượng động quét mặt
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: const Icon(
                  Icons.face_retouching_natural_rounded,
                  color: Colors.white,
                  size: 48,
                ),
              ),
              const SizedBox(height: 32),
              
              // Text trạng thái
              Obx(() => Text(
                controller.statusMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              )),
              const SizedBox(height: 20),
              
              // Thanh Progress Bar với hiệu ứng mượt mà
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: Obx(() {
                  final progressValue = controller.scanProgress.value;
                  return TweenAnimationBuilder<double>(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOutCubic,
                    tween: Tween<double>(begin: 0.0, end: progressValue),
                    builder: (context, value, child) {
                      return Column(
                        children: [
                          LinearProgressIndicator(
                            value: value,
                            minHeight: 8,
                            backgroundColor: Colors.white.withValues(alpha: 0.12),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primaryContainer),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${(value * 100).toInt()}%',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.7),
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      );
                    },
                  );
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 44,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'THÀNH CÔNG',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.success,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),
              Obx(() => Text(
                controller.statusMessage.value,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppColors.onBackground,
                ),
              )),
              const SizedBox(height: 12),
              if (controller.mode == 'attendance') ...[
                Text(
                  'Hệ thống đã tự động tích chọn đi học.',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[500],
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 24),
                const Divider(height: 1),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(result: true),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Xong',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => controller.restartScanning(),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Quét tiếp',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.72),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerLowest,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'LỖI NHẬN DIỆN',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() => Text(
                controller.statusMessage.value.replaceFirst('Thất bại: ', ''),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.onBackground,
                  height: 1.4,
                ),
              )),
              const SizedBox(height: 28),
              const Divider(height: 1),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Đóng',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => controller.restartScanning(),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Thử lại',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FaceScanOverlayPainter extends CustomPainter {
  final FaceScanState state;
  _FaceScanOverlayPainter({required this.state});

  @override
  void paint(Canvas canvas, Size size) {
    // Căn tỷ lệ khung oval vẽ khuôn mặt bé (thu nhỏ lại một chút để khoảng cách quét tự nhiên hơn)
    final double ovalW = size.width * 0.60;
    final double ovalH = size.height * 0.35;
    
    final double left = (size.width - ovalW) / 2;
    final double top = (size.height - ovalH) / 2 - 40; // Đẩy khung oval lên trên một chút để cân đối tầm mắt
    
    final Rect ovalRect = Rect.fromLTWH(left, top, ovalW, ovalH);
    final RRect rrect = RRect.fromRectAndRadius(ovalRect, Radius.elliptical(ovalW / 2, ovalH / 2));

    // 1. Vẽ vùng tối che phần camera ngoài khung oval
    final Paint overlayPaint = Paint()..color = Colors.black.withValues(alpha: 0.68);
    final Path path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(rrect)
      ..fillType = PathFillType.evenOdd;
    canvas.drawPath(path, overlayPaint);

    // 2. Vẽ viền oval có màu sắc thay đổi tương ứng trạng thái quét
    Color borderColor = Colors.white.withValues(alpha: 0.35);
    
    if (state == FaceScanState.analyzing) {
      borderColor = AppColors.primary;
    } else if (state == FaceScanState.success) {
      borderColor = AppColors.success;
    } else if (state == FaceScanState.error) {
      borderColor = AppColors.error;
    } else if (state == FaceScanState.ready) {
      borderColor = AppColors.primary.withValues(alpha: 0.8);
    }

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.5;

    canvas.drawRRect(rrect, borderPaint);

    // Vẽ thêm 4 góc định vị trang trí ngoài viền oval
    final Paint cornerPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
      
    // Vẽ bounding box chữ nhật định vị nhẹ
    canvas.drawRect(
      Rect.fromLTWH(left - 10, top - 10, ovalW + 20, ovalH + 20),
      cornerPaint
    );
  }

  @override
  bool shouldRepaint(_FaceScanOverlayPainter old) => old.state != state;
}
