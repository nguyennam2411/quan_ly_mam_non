import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/values/app_database.dart';
import '../../../../data/models/health_record_model.dart';
import '../../../../data/repositories/health_record_repository.dart';

/// Model tạm để quản lý trạng thái nhập liệu của từng hàng trong bảng.
class HealthInputRow {
  final String studentId;
  final String studentName;
  final String? avatarUrl;

  final TextEditingController heightCtrl;
  final TextEditingController weightCtrl;

  // Dữ liệu hiện tại (nếu đã có hồ sơ tháng này)
  String? existingRecordId;

  HealthInputRow({
    required this.studentId,
    required this.studentName,
    this.avatarUrl,
    this.existingRecordId,
    String initialHeight = '',
    String initialWeight = '',
  })  : heightCtrl = TextEditingController(text: initialHeight),
        weightCtrl = TextEditingController(text: initialWeight);

  double? get height => double.tryParse(heightCtrl.text);
  double? get weight => double.tryParse(weightCtrl.text);

  double? get bmi {
    final h = height;
    final w = weight;
    if (h == null || w == null || h <= 0) return null;
    return HealthRecordModel.calculateBmi(h, w);
  }

  String get bmiLabel {
    final b = bmi;
    if (b == null) return '—';
    if (b < 14.0) return 'Suy dinh dưỡng';
    if (b < 18.5) return 'Bình thường';
    if (b < 22.0) return 'Thừa cân';
    return 'Béo phì';
  }

  void dispose() {
    heightCtrl.dispose();
    weightCtrl.dispose();
  }
}

class HealthController extends GetxController {
  final HealthRecordRepository _repository;
  HealthController({required HealthRecordRepository repository})
      : _repository = repository;

  final RxBool isLoading = false.obs;
  final RxBool isSaving = false.obs;
  final Rx<DateTime> selectedMonth = DateTime.now().obs;
  final RxList<HealthInputRow> rows = <HealthInputRow>[].obs;

  String get classroomId => AuthService.to.classroomId.value;
  String get teacherId => AuthService.to.currentUser.value?.id ?? '';

  @override
  void onInit() {
    super.onInit();
    fetchData();
  }

  @override
  void onClose() {
    for (final row in rows) {
      row.dispose();
    }
    super.onClose();
  }

  // Lấy dữ liệu từ API
  Future<void> fetchData() async {
    if (classroomId.isEmpty) {
      debugPrint('HealthController: classroomId is empty, skipping fetch.');
      Get.snackbar('Lưu ý', 'Tài khoản chưa được gán lớp học');
      return;
    }
    try {
      isLoading.value = true;
      // Clear old rows safely
      for (final row in rows) {
        row.dispose();
      }
      rows.clear();

      final data = await _repository.getStudentsWithHealth(
        classroomId: classroomId,
        month: selectedMonth.value,
      );

      final newRows = data.map((student) {
        // Lấy hồ sơ sức khỏe nếu có (join left)
        final healthList = student[AppDatabase.tableHealthRecords];
        Map<String, dynamic>? health;
        if (healthList is List && healthList.isNotEmpty) {
          health = healthList.first as Map<String, dynamic>;
        }

        final h = health != null
            ? (health[AppDatabase.colHeight] as num?)?.toDouble()
            : null;
        final w = health != null
            ? (health[AppDatabase.colWeight] as num?)?.toDouble()
            : null;

        return HealthInputRow(
          studentId: student[AppDatabase.colId] as String,
          studentName: student[AppDatabase.colName] as String,
          avatarUrl: student[AppDatabase.colAvatarUrl] as String?,
          existingRecordId: health?[AppDatabase.colId] as String?,
          initialHeight: h != null ? h.toStringAsFixed(2) : '',
          initialWeight: w != null ? w.toStringAsFixed(1) : '',
        );
      }).toList();

      rows.assignAll(newRows);
    } catch (e, stack) {
      debugPrint('HealthController.fetchData error: $e\n$stack');
      Get.snackbar('Lỗi', 'Không thể tải dữ liệu sức khỏe: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Lưu dữ liệu
  Future<void> saveAll() async {
    final records = <Map<String, dynamic>>[];
    final now = DateTime.now();
    final isCurrentMonth = selectedMonth.value.year == now.year && selectedMonth.value.month == now.month;
    final day = isCurrentMonth ? now.day : 1;
    final dateStr = '${selectedMonth.value.year}-${selectedMonth.value.month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';

    for (final row in rows) {
      final h = row.height;
      final w = row.weight;
      if (h == null || w == null) continue;

      if (h <= 0 || w <= 0) {
        Get.snackbar('Lỗi dữ liệu',
            'Chiều cao và cân nặng của ${row.studentName} phải lớn hơn 0',
            backgroundColor: Colors.red.withOpacity(0.8),
            colorText: Colors.white);
        return;
      }

      final bmi = HealthRecordModel.calculateBmi(h, w);

      records.add({
        AppDatabase.colStudentId: row.studentId,
        AppDatabase.colHeight: h,
        AppDatabase.colWeight: w,
        AppDatabase.colBmi: double.parse(bmi.toStringAsFixed(2)),
        AppDatabase.colDate: dateStr,
        AppDatabase.colTeacherId: teacherId,
      });
    }

    if (records.isEmpty) {
      Get.snackbar('Lưu ý', 'Chưa có dữ liệu nào để lưu');
      return;
    }

    try {
      isSaving.value = true;
      await _repository.saveHealthRecords(records);
      Get.snackbar('Thành công', 'Đã lưu ${records.length} hồ sơ sức khỏe',
          backgroundColor: const Color(0xFF2E7D32),
          colorText: const Color(0xFFF1F8F1));
    } catch (e, stack) {
      debugPrint('HealthController.saveAll error: $e\n$stack');
      Get.snackbar('Lỗi', 'Không thể lưu dữ liệu. Vui lòng thử lại.');
    } finally {
      isSaving.value = false;
    }
  }

  void changeMonth(DateTime month) {
    selectedMonth.value = month;
    fetchData(); 
  }

  void prevMonth() {
    final m = selectedMonth.value;
    changeMonth(DateTime(m.year, m.month - 1, 1));
  }

  void nextMonth() {
    final m = selectedMonth.value;
    changeMonth(DateTime(m.year, m.month + 1, 1));
  }
}
