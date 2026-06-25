import 'package:fl_chart/fl_chart.dart';
import 'package:get/get.dart';
import '../../../../core/data/who_growth_data.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/health_record_model.dart';
import '../../../../data/repositories/health_record_repository.dart';
import '../../../../global_widgets/charts/app_line_chart.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/utils/app_error_message.dart';
import '../../../../core/values/app_strings.dart';

class ParentHealthController extends GetxController {
  final HealthRecordRepository _repository;
  ParentHealthController({required HealthRecordRepository repository})
      : _repository = repository;

  final _studentService = ParentStudentService.to;
  final RxBool isLoading = false.obs;
  final RxList<HealthRecordModel> history = <HealthRecordModel>[].obs;
  final RxInt chartTab = 0.obs; // 0 = Chiều cao, 1 = Cân nặng
  final RxBool isMissingInfo = false.obs; // Cảnh báo thiếu ngày sinh/giới tính
  final List<Worker> _workers = [];

  @override
  void onInit() {
    super.onInit();
    fetchHistory();
    _workers.add(ever(_studentService.selectedStudent, (_) => fetchHistory()));
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
      AppDialogs.error(message: AppErrorMessage.from(e));
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

  // Xử lý dữ liệu để vẽ biểu đồ
  List<AppLineData> buildChartLines(bool isHeight) {
    final student = _studentService.selectedStudent.value;
    if (history.isEmpty || student == null) return [];

    final birthday = student.birthday;
    final gender = student.gender;
    final isBoy = gender?.toUpperCase() == 'MALE';

    // Lọc danh sách: Mỗi tháng/năm chỉ lấy 1 bản ghi mới nhất để vẽ biểu đồ
    final Map<String, HealthRecordModel> monthlyLatest = {};
    for (var record in history) {
      final key = '${record.date.year}-${record.date.month}';
      // Do history đã được sắp xếp theo date asc (trong provider), nên bản ghi sau sẽ tự động là bản ghi mới nhất của tháng đó.
      monthlyLatest[key] = record;
    }

    final filteredHistory = monthlyLatest.values.toList();
    // Sắp xếp lại danh sách đã lọc theo thời gian để vẽ đường line đúng hướng
    filteredHistory.sort((a, b) => a.date.compareTo(b.date));

    // Đường của bé (vẽ từ danh sách đã lọc)
    final babySpots = filteredHistory.map((record) {
      final x = birthday != null 
          ? _calculateMonthAge(birthday, record.date) 
          : filteredHistory.indexOf(record).toDouble(); 
      
      final value = isHeight
          ? record.height * 100 // m → cm
          : record.weight;
      return FlSpot(x, value);
    }).toList();

    // Đảm bảo các điểm vẽ biểu đồ theo thứ tự X tăng dần
    babySpots.sort((a, b) => a.x.compareTo(b.x));

    List<FlSpot> medianSpots = [];
    List<FlSpot> plus2Spots = [];
    List<FlSpot> minus2Spots = [];

    // Chỉ vẽ đường WHO khi có đủ thông tin đối chiếu
    if (!isMissingInfo.value) {
      final whoData = WhoGrowthData.getChartPoints(isBoy: isBoy, isHeight: isHeight);
      double maxBabyMonth = babySpots.isNotEmpty ? babySpots.last.x : 0;
      // Lấy dữ liệu WHO đến tháng của bé + 6 tháng
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
          color: AppColors.onSurfaceVariant.withValues(alpha: 0.5),
          label: AppStrings.healthWhoStandard,
          isDashed: true,
          strokeWidth: 1.5,
        ),
        AppLineData(
          spots: plus2Spots,
          color: AppColors.warning.withValues(alpha: 0.6),
          label: AppStrings.healthHighThreshold,
          isDashed: true,
          strokeWidth: 1,
        ),
        AppLineData(
          spots: minus2Spots,
          color: AppColors.error.withValues(alpha: 0.6),
          label: AppStrings.healthLowThreshold,
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
        label: isHeight ? AppStrings.healthHeightCm : AppStrings.healthWeightKg,
        isDashed: false,
        strokeWidth: 3,
      ),
    );

    return lines;
  }
  // Xây dựng chú thích cho biểu đồ
  List<Map<String, dynamic>> buildLegend(bool isHeight) {
    final legend = [
      {'label': _studentService.selectedStudent.value?.name ?? AppStrings.healthChildLabel, 'color': AppColors.primary, 'isDashed': false},
    ];

    if (!isMissingInfo.value) {
      legend.addAll([
        {'label': AppStrings.healthWhoStandard, 'color': AppColors.onSurfaceVariant.withValues(alpha: 0.5), 'isDashed': true},
        {'label': AppStrings.healthHighThreshold, 'color': AppColors.warning, 'isDashed': true},
        {'label': AppStrings.healthLowThreshold, 'color': AppColors.error, 'isDashed': true},
      ]);
    }

    return legend;
  }
  @override
  void onClose() {
    for (var worker in _workers) {
      worker.dispose();
    }
    super.onClose();
  }
}
