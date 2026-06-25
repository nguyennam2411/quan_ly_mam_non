import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/repositories/attendance_repository.dart';
import 'attendance_controller.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../core/utils/app_error_message.dart';

// Trạng thái sau mỗi lần quét
enum QrScanState { success, error }

class QrScanResult {
  final QrScanState state;
  final String title;    // Tên bé (success) hoặc thông báo lỗi (error)
  final String subtitle; // Giờ check-in hoặc mô tả cập nhật

  const QrScanResult({
    required this.state,
    required this.title,
    this.subtitle = '',
  });
}

class QrScannerController extends GetxController {
  final AttendanceRepository _repository = AttendanceRepository();

  // Camera controller – dùng để pause/resume
  final MobileScannerController cameraController = MobileScannerController();

  // null = đang chờ quét, có giá trị = đang hiện kết quả
  final Rxn<QrScanResult> scanResult = Rxn<QrScanResult>();

  bool _isProcessing = false;
  int _successCount = 0; // Dùng để trả về result khi back

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }

  Future<void> onCodeScanned(String code) async {
    // Bỏ qua nếu đang xử lý hoặc đang hiện kết quả
    if (_isProcessing || scanResult.value != null) return;
    _isProcessing = true;

    // Tạm dừng camera ngay lập tức để tránh quét liên tục
    await cameraController.stop();

    try {
      final classroomId = AuthService.to.classroomId.value;
      final teacherId = AuthService.to.currentUser.value?.id ?? '';

      final result = await _repository.checkInByQrCode(
        qrCode: code,
        teacherId: teacherId,
        classroomId: classroomId,
      );

      _successCount++;

      // Cập nhật danh sách ở màn hình phía sau ngay lập tức
      if (Get.isRegistered<AttendanceController>()) {
        await Get.find<AttendanceController>().fetchAttendanceList();
      }

      final timeStr = DateFormat('HH:mm').format(DateTime.now());
      final subtitle = result.isLateArrival
          ? '${AppStrings.attendanceQrUpdateLate}$timeStr'
          : '${AppStrings.attendanceQrCheckinAtTime}$timeStr';

      scanResult.value = QrScanResult(
        state: QrScanState.success,
        title: result.studentName,
        subtitle: subtitle,
      );
    } catch (e) {
      scanResult.value = QrScanResult(
        state: QrScanState.error,
        title: AppErrorMessage.from(e),
      );
    } finally {
      _isProcessing = false;
    }
  }

  // Tiếp tục quét (Quét tiếp / Thử lại)
  Future<void> resumeScanning() async {
    scanResult.value = null;
    await cameraController.start();
  }

  // Hoàn thành (Xong / Đóng)
  void finishScanning() {
    Get.back(result: _successCount > 0);
  }
}