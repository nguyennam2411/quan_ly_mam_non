import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/repositories/attendance_repository.dart';
import '../../../../global_widgets/charts/app_bar_chart.dart';
import '../../../../global_widgets/charts/app_pie_chart.dart';

class AttendanceStatisticController extends GetxController {
  final AttendanceRepository repository;
  AttendanceStatisticController({required this.repository});

  // --- STATE ---
  var isLoading = false.obs;
  
  // Lọc thời gian
  var selectedMonth = DateTime.now().obs;
  var selectedWeek = DateTime.now().obs;

  // Dữ liệu thô từ RPC
  var monthlyRawData = <Map<String, dynamic>>[].obs;
  var weeklyRawData = <Map<String, dynamic>>[].obs;

  // Tổng hợp kết quả
  var totalMonthlySessions = 0.obs; // Tổng số lượt (để tính %)
  var totalAttendanceDays = 0.obs;  // Số ngày thực tế
  var presentPercentage = 0.0.obs;

  String get currentClassId => AuthService.to.classroomId.value;

  @override
  void onInit() {
    super.onInit();
    // Khởi tạo tuần hiện tại (bắt đầu từ Thứ 2)
    selectedWeek.value = _findFirstDayOfWeek(DateTime.now());
    fetchAllData();
  }

  void fetchAllData() {
    fetchMonthlyData();
    fetchWeeklyData();
  }

  // --- LOGIC FETCH ---

  Future<void> fetchMonthlyData() async {
    if (currentClassId.isEmpty) return;
    isLoading.value = true;
    try {
      final firstDay = DateTime(selectedMonth.value.year, selectedMonth.value.month, 1);
      final lastDay = DateTime(selectedMonth.value.year, selectedMonth.value.month + 1, 0);

      final result = await repository.getAttendanceStatsReport(
        classroomId: currentClassId,
        startDate: firstDay,
        endDate: lastDay,
      );
      monthlyRawData.assignAll(result);
      _calculateMonthlyStats();
    } catch (e) {
      debugPrint("Error fetching monthly stats: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchWeeklyData() async {
    if (currentClassId.isEmpty) return;
    try {
      final startOfWeek = selectedWeek.value;
      final endOfWeek = startOfWeek.add(const Duration(days: 4)); // T2 -> T6 (5 ngày)

      final result = await repository.getAttendanceStatsReport(
        classroomId: currentClassId,
        startDate: startOfWeek,
        endDate: endOfWeek,
      );
      weeklyRawData.assignAll(result);
    } catch (e) {
      debugPrint("Error fetching weekly stats: $e");
    }
  }

  // --- LOGIC XỬ LÝ DỮ LIỆU ---

  void _calculateMonthlyStats() {
    int total = 0;
    int present = 0;
    for (var item in monthlyRawData) {
      int count = int.tryParse(item['count'].toString()) ?? 0;
      total += count;
      if (item['status'] == AppDatabase.statusPresent) {
        present += count;
      }
    }
    totalMonthlySessions.value = total;
    // Đếm số ngày duy nhất từ dữ liệu RPC (field 'attendance_date')
    totalAttendanceDays.value = monthlyRawData.map((e) => e['attendance_date']).toSet().length;
    presentPercentage.value = total > 0 ? (present / total) * 100 : 0.0;
  }

  // --- GETTERS CHO BIỂU ĐỒ ---

  double get weeklyMaxY {
    double max = 0;
    for (var item in weeklyRawData) {
      double count = double.tryParse(item['count'].toString()) ?? 0;
      if (count > max) max = count;
    }
    return max + 2;
  }

  List<AppBarGroup> get weeklyChartGroups {
    final Map<String, Map<String, double>> dailyCounts = {};
    for (int i = 0; i < 5; i++) {
      final dateStr = selectedWeek.value.add(Duration(days: i)).toIso8601String().split('T')[0];
      dailyCounts[dateStr] = {'present': 0.0, 'absent': 0.0};
    }

    for (var item in weeklyRawData) {
      final date = item['attendance_date'] as String;
      final status = item['status'] as String;
      final count = double.tryParse(item['count'].toString()) ?? 0.0;

      if (dailyCounts.containsKey(date)) {
        if (status == AppDatabase.statusPresent) {
          dailyCounts[date]!['present'] = (dailyCounts[date]!['present'] ?? 0.0) + count;
        } else {
          dailyCounts[date]!['absent'] = (dailyCounts[date]!['absent'] ?? 0.0) + count;
        }
      }
    }

    List<AppBarGroup> groups = [];
    int index = 0;
    dailyCounts.forEach((date, counts) {
      groups.add(AppBarGroup(
        x: index,
        values: [counts['present']!, counts['absent']!],
        colors: [AppColors.primary, AppColors.error],
      ));
      index++;
    });
    return groups;
  }

  List<AppPieData> get monthlyChartData {
    final Map<String, double> counts = {};
    double total = 0;

    for (var item in monthlyRawData) {
      final status = item['status'] as String;
      final count = double.tryParse(item['count'].toString()) ?? 0.0;
      counts[status] = (counts[status] ?? 0.0) + count;
      total += count;
    }

    if (total == 0) return [];

    return [
      if ((counts[AppDatabase.statusPresent] ?? 0) > 0)
        AppPieData(
          value: counts[AppDatabase.statusPresent]!,
          color: AppColors.primary,
          label: AppStrings.attendancePresent,
        ),
      if ((counts[AppDatabase.statusAbsentExcused] ?? 0) > 0)
        AppPieData(
          value: counts[AppDatabase.statusAbsentExcused]!,
          color: AppColors.warning,
          label: AppStrings.attendanceExcused,
        ),
      if ((counts[AppDatabase.statusAbsentUnexcused] ?? 0) > 0)
        AppPieData(
          value: counts[AppDatabase.statusAbsentUnexcused]!,
          color: AppColors.error,
          label: AppStrings.attendanceUnexcused,
        ),
    ];
  }

  List<Map<String, dynamic>> get weeklyLegend => [
    {'label': AppStrings.attendancePresent, 'color': AppColors.primary},
    {'label': AppStrings.attendanceAbsentLabel, 'color': AppColors.error},
  ];

  List<Map<String, dynamic>> get monthlyLegend => [
    {'label': AppStrings.attendancePresent, 'color': AppColors.primary},
    {'label': AppStrings.attendanceExcused, 'color': AppColors.warning},
    {'label': AppStrings.attendanceUnexcused, 'color': AppColors.error},
  ];

  // Helper tìm ngày Thứ 2 của tuần chứa date
  DateTime _findFirstDayOfWeek(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  // --- ACTION METHODS ---

  void changeMonth(DateTime month) {
    selectedMonth.value = month;
    fetchMonthlyData();
  }

  void changeWeek(DateTime dateInWeek) {
    selectedWeek.value = _findFirstDayOfWeek(dateInWeek);
    fetchWeeklyData();
  }

  // Điều hướng nhanh
  void nextMonth() {
    selectedMonth.value = DateTime(selectedMonth.value.year, selectedMonth.value.month + 1, 1);
    fetchMonthlyData();
  }

  void prevMonth() {
    selectedMonth.value = DateTime(selectedMonth.value.year, selectedMonth.value.month - 1, 1);
    fetchMonthlyData();
  }

  void nextWeek() {
    selectedWeek.value = selectedWeek.value.add(const Duration(days: 7));
    fetchWeeklyData();
  }

  void prevWeek() {
    selectedWeek.value = selectedWeek.value.subtract(const Duration(days: 7));
    fetchWeeklyData();
  }
}
