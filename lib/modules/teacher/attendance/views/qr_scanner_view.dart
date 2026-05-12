import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../global_widgets/headers/main_app_bar.dart';
import '../controllers/qr_scanner_controller.dart';

class QrScannerView extends GetView<QrScannerController> {
  const QrScannerView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: const MainAppBar(title: 'Quét mã điểm danh'),
      body: Stack(
        children: [
          // 1. Camera feed (full screen)
          MobileScanner(
            controller: controller.cameraController,
            onDetect: (capture) {
              final rawValue = capture.barcodes.firstOrNull?.rawValue;
              if (rawValue != null) controller.onCodeScanned(rawValue);
            },
          ),

          // 2. Dark overlay + khung quét + hướng dẫn
          const _ScanFrame(),

          // 3. Overlay kết quả (hiện sau mỗi lần quét)
          Obx(() {
            final result = controller.scanResult.value;
            if (result == null) return const SizedBox.shrink();
            return _ResultOverlay(result: result);
          }),
        ],
      ),
    );
  }
}

// ─── Khung quét với animation scan line ─────────────────────────────────────

class _ScanFrame extends StatefulWidget {
  const _ScanFrame();

  @override
  State<_ScanFrame> createState() => _ScanFrameState();
}

class _ScanFrameState extends State<_ScanFrame>
    with SingleTickerProviderStateMixin {
  late AnimationController _anim;

  // AnimationController dùng để tạo animation scan line
  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
      vsync: this, // sử dụng SingleTickerProviderStateMixin để đồng bộ animation với frame rate của thiết bị
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true); // repeat(reverse: true) có nghĩa là lặp lại animation từ đầu đến cuối và ngược lại
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }
  
  // build dùng để vẽ khung quét
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, _) {
        return CustomPaint(
          painter: _ScanOverlayPainter(progress: _anim.value),
          child: const SizedBox.expand(),
        );
      },
    );
  }
}

// dùng để vẽ khung quét
class _ScanOverlayPainter extends CustomPainter {
  final double progress;
  _ScanOverlayPainter({required this.progress});

  // paint dùng để vẽ khung quét
  @override
  void paint(Canvas canvas, Size size) {
    final frameSize = size.width * 0.70; // kích thước khung quét so với màn hình
    final left = (size.width - frameSize) / 2; // khoảng cách từ mép trái màn hình đến mép trái khung quét
    final top = (size.height - frameSize) / 2 - 24; // khoảng cách từ mép trên màn hình đến mép trên khung quét
    final scanRect = Rect.fromLTWH(left, top, frameSize, frameSize); 
    const radius = Radius.circular(16);

    // --- Overlay gelap ---
    final overlayPaint = Paint()..color = Colors.black.withOpacity(0.62); 
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height)) // vẽ overlay
      ..addRRect(RRect.fromRectAndRadius(scanRect, radius)) // vẽ khung
      ..fillType = PathFillType.evenOdd; // fillType.evenOdd có nghĩa là fill cả phần bên trong và bên ngoài khung
    canvas.drawPath(path, overlayPaint);

    // --- Viền mỏng quanh khung ---
    canvas.drawRRect(
      RRect.fromRectAndRadius(scanRect, radius),
      Paint()
        ..color = Colors.white.withOpacity(0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // --- Góc trắng (corner brackets) ---
    const cLen = 28.0;
    const cW = 3.5;
    final cPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = cW
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    void drawCorner(Offset pt, double dx, double dy) {
      canvas.drawLine(pt, pt + Offset(dx * cLen, 0), cPaint);
      canvas.drawLine(pt, pt + Offset(0, dy * cLen), cPaint);
    }

    drawCorner(scanRect.topLeft, 1, 1);
    drawCorner(scanRect.topRight, -1, 1);
    drawCorner(scanRect.bottomLeft, 1, -1);
    drawCorner(scanRect.bottomRight, -1, -1);

    // --- Scan line ---
    final scanY = scanRect.top + progress * frameSize;
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          Colors.transparent,
          AppColors.primary.withOpacity(0.8),
          Colors.transparent,
        ],
      ).createShader(scanRect);
    canvas.drawLine(
      Offset(scanRect.left + 8, scanY),
      Offset(scanRect.right - 8, scanY),
      linePaint..strokeWidth = 2.5,
    );

    // --- Hướng dẫn bên dưới khung ---
    final tp = TextPainter(
      text: TextSpan(
        text: 'Đưa mã QR của bé vào khung hình',
        style: TextStyle(
          color: Colors.white.withOpacity(0.75),
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width - 48);
    tp.paint(canvas, Offset((size.width - tp.width) / 2, scanRect.bottom + 20));
  }

  @override
  bool shouldRepaint(_ScanOverlayPainter old) => old.progress != progress;
}

// ─── Overlay kết quả ────────────────────────────────────────────────────────

class _ResultOverlay extends GetView<QrScannerController> {
  final QrScanResult result;
  const _ResultOverlay({required this.result});

  bool get _isSuccess => result.state == QrScanState.success;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black.withOpacity(0.72),
      alignment: Alignment.center,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.18),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: _isSuccess
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFE65100),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _isSuccess ? Icons.check_rounded : Icons.warning_amber_rounded,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 16),

              // Label trên
              Text(
                _isSuccess ? 'Đã điểm danh' : 'Không thể điểm danh',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: _isSuccess
                      ? const Color(0xFF2E7D32)
                      : const Color(0xFFE65100),
                  letterSpacing: 0.4,
                ),
              ),
              const SizedBox(height: 6),

              // Tên bé / lỗi
              Text(
                result.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF1A1A2E),
                  height: 1.3,
                ),
              ),

              // Subtitle (giờ check-in / loại cập nhật)
              if (result.subtitle.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  result.subtitle,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],

              const SizedBox(height: 28),
              const Divider(height: 1),
              const SizedBox(height: 16),

              // Buttons
              Row(
                children: [
                  // Xong / Đóng
                  Expanded(
                    child: OutlinedButton(
                      onPressed: controller.finishScanning,
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        side: BorderSide(color: Colors.grey[300]!),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isSuccess ? 'Xong' : 'Đóng',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.grey[700],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Quét tiếp / Thử lại
                  Expanded(
                    child: ElevatedButton(
                      onPressed: controller.resumeScanning,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        backgroundColor: _isSuccess
                            ? AppColors.primary
                            : const Color(0xFFE65100),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        _isSuccess ? 'Quét tiếp' : 'Thử lại',
                        style: const TextStyle(fontWeight: FontWeight.w700),
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