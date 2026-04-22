import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/data/who_growth_data.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/health_record_model.dart';
import '../../../../data/repositories/health_record_repository.dart';
import '../../../../global_widgets/charts/app_line_chart.dart';

class ParentHealthController extends GetxController {
  final HealthRecordRepository _repository;
  ParentHealthController({required HealthRecordRepository repository})
      : _repository = repository;

  final _studentService = ParentStudentService.to;
  final RxBool isLoading = false.obs;
  final RxList<HealthRecordModel> history = <HealthRecordModel>[].obs;
  final RxInt chartTab = 0.obs; // 0 = Chiều cao, 1 = Cân nặng
  final RxBool isMissingInfo = false.obs; // Cảnh báo thiếu ngày sinh/giới tính

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
    ever(_studentService.selectedStudent, (_) => fetchHistory());
  }

  Future<void> fetchHistory() async {
    final student = _studentService.selectedStudent.value;
    if (student == null) return;
    try {
      isLoading.value = true;
      final data = await _repository.getStudentGrowthHistory(student.id);
      history.assignAll(data);
      
      // Cập nhật trạng thái thiếu thông tin ngay khi có dữ liệu học sinh
      isMissingInfo.value = student.birthday == null || student.gender == null;
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải dữ liệu sức khoẻ');
    } finally {
      isLoading.value = false;
    }
  }

  HealthRecordModel? get latestRecord =>
      history.isNotEmpty ? history.last : null;

  /// Tính tháng tuổi từ ngày sinh của bé đến ngày ghi nhận record
  double _calculateMonthAge(DateTime birthday, DateTime recordDate) {
    int months = (recordDate.year - birthday.year) * 12 + recordDate.month - birthday.month;
    // Thêm phần lẻ ngày nếu cần chính xác hơn, nhưng với chuẩn tháng thì số nguyên là đủ
    return months.toDouble();
  }

  List<AppLineData> buildChartLines(bool isHeight) {
    final student = _studentService.selectedStudent.value;
    if (history.isEmpty || student == null) return [];

    final birthday = student.birthday;
    final gender = student.gender;
    final isBoy = gender?.toUpperCase() == 'MALE';

    // XÓA LÔ-GIC CẬP NHẬT Ở ĐÂY ĐỂ TRÁNH LỖI BUILD CYCLE
    // isMissingInfo.value = birthday == null || gender == null;

    // Đường của bé
    final babySpots = history.map((record) {
      final x = birthday != null 
          ? _calculateMonthAge(birthday, record.date) 
          : history.indexOf(record).toDouble(); 
      
      final value = isHeight
          ? record.height * 100 // m → cm
          : record.weight;
      return FlSpot(x, value);
    }).toList();

    // Sắp xếp các điểm đo theo tháng tuổi tăng dần
    babySpots.sort((a, b) => a.x.compareTo(b.x));

    List<FlSpot> medianSpots = [];
    List<FlSpot> plus2Spots = [];
    List<FlSpot> minus2Spots = [];

    // Chỉ vẽ đường WHO khi có đủ thông tin đối chiếu
    if (!isMissingInfo.value) {
      final whoData = WhoGrowthData.getChartPoints(isBoy: isBoy, isHeight: isHeight);
      double maxBabyMonth = babySpots.isNotEmpty ? babySpots.last.x : 0;

      for (var point in whoData) {
        final x = point['month']!;
        if (x <= maxBabyMonth + 6) {
          medianSpots.add(FlSpot(x, point['median']!));
          plus2Spots.add(FlSpot(x, point['plus2']!));
          minus2Spots.add(FlSpot(x, point['minus2']!));
        }
      }
    }

    final lines = <AppLineData>[];
    
    // Chỉ thêm các đường WHO vào danh sách nếu có dữ liệu
    if (medianSpots.isNotEmpty) {
      lines.addAll([
        AppLineData(
          spots: medianSpots,
          color: AppColors.onSurfaceVariant.withOpacity(0.5),
          label: 'Chuẩn WHO',
          isDashed: true,
          strokeWidth: 1.5,
        ),
        AppLineData(
          spots: plus2Spots,
          color: AppColors.warning.withOpacity(0.6),
          label: 'Ngưỡng cao',
          isDashed: true,
          strokeWidth: 1,
        ),
        AppLineData(
          spots: minus2Spots,
          color: AppColors.error.withOpacity(0.6),
          label: 'Ngưỡng thấp',
          isDashed: true,
          strokeWidth: 1,
        ),
      ]);
    }

    // Luôn thêm đường của bé
    lines.add(
      AppLineData(
        spots: babySpots,
        color: AppColors.primary,
        label: isHeight ? 'Chiều cao (cm)' : 'Cân nặng (kg)',
        isDashed: false,
        strokeWidth: 3,
      ),
    );

    return lines;
  }

  List<Map<String, dynamic>> buildLegend(bool isHeight) {
    final legend = [
      {'label': _studentService.selectedStudent.value?.name ?? 'Của bé', 'color': AppColors.primary, 'isDashed': false},
    ];

    if (!isMissingInfo.value) {
      legend.addAll([
        {'label': 'Chuẩn WHO', 'color': AppColors.onSurfaceVariant.withOpacity(0.5), 'isDashed': true},
        {'label': 'Ngưỡng cao', 'color': AppColors.warning, 'isDashed': true},
        {'label': 'Ngưỡng thấp', 'color': AppColors.error, 'isDashed': true},
      ]);
    }

    return legend;
  }
}
