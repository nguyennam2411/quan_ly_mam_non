import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_datepicker/datepicker.dart';
import 'package:quan_ly_mam_non/routes/app_routes.dart';
import 'package:quan_ly_mam_non/data/repositories/attendance_repository.dart';
import 'package:quan_ly_mam_non/data/models/attendance_model.dart';
import 'package:quan_ly_mam_non/core/services/auth_service.dart';
import 'package:quan_ly_mam_non/core/values/app_database.dart';
import 'package:quan_ly_mam_non/core/values/app_strings.dart';
import 'package:quan_ly_mam_non/core/utils/dialog.dart';
import 'package:quan_ly_mam_non/core/utils/app_error_message.dart';

enum AttendanceFilter {
  all,
  notTaken,
  present,
  absent,
}

class AttendanceController extends GetxController {
  final AttendanceRepository repository;
  AttendanceController({required this.repository});

  // --- STATE VARIABLES ---
  
  // ID lớp học của giáo viên (lấy từ AuthService)
  String get currentClassId => AuthService.to.classroomId.value;

  var selectedDate = DateTime.now().obs;
  var isLoading = false.obs;
  var isEditMode = false.obs;
  var searchQuery = ''.obs;
  var hasChanges = false.obs;
  var selectedFilter = AttendanceFilter.all.obs;
  
  // Controller cho phần Lịch (SfDateRangePicker)
  final DateRangePickerController calendarController = DateRangePickerController();

  // Dữ liệu hiển thị (Key dạng yyyy-MM-dd để tránh lỗi timezone/equality)
  var monthlyStatus = <String, bool>{}.obs; 
  var studentsWithAttendance = <StudentWithAttendance>[].obs;

  // --- GETTERS ---

  bool get isToday => DateUtils.isSameDay(selectedDate.value, DateTime.now());
  bool get isPast => selectedDate.value.isBefore(DateTime.now()) && !isToday;
  bool get isFuture => selectedDate.value.isAfter(DateTime.now()) && !isToday;

  bool get canAttendance => isToday;
  bool get canViewHistory => true; // Cho phép xem bất kỳ ngày nào (quá khứ, hiện tại, tương lai)

  // Đếm sĩ số nhanh
  int get totalCount => studentsWithAttendance.length;
  int get presentCount => studentsWithAttendance.where((e) => e.attendance?.status == AppDatabase.statusPresent).length;
  int get absentCount => studentsWithAttendance.where((e) => 
      e.attendance?.status == AppDatabase.statusAbsentUnexcused || e.attendance?.status == AppDatabase.statusAbsentExcused).length;

  // Đếm số lượng bộ lọc
  int get allFilterCount => studentsWithAttendance.length;
  int get notTakenFilterCount => studentsWithAttendance.where((e) => e.attendance == null).length;
  int get presentFilterCount => studentsWithAttendance.where((e) => e.attendance?.status == AppDatabase.statusPresent).length;
  int get absentFilterCount => studentsWithAttendance.where((e) => 
      e.attendance?.status == AppDatabase.statusAbsentExcused || e.attendance?.status == AppDatabase.statusAbsentUnexcused).length;

  // Danh sách đã lọc theo bộ lọc trạng thái và tìm kiếm
  List<StudentWithAttendance> get filteredStudents {
    List<StudentWithAttendance> list = studentsWithAttendance;
    
    // 1. Lọc theo trạng thái điểm danh
    switch (selectedFilter.value) {
      case AttendanceFilter.notTaken:
        list = list.where((e) => e.attendance == null).toList();
        break;
      case AttendanceFilter.present:
        list = list.where((e) => e.attendance?.status == AppDatabase.statusPresent).toList();
        break;
      case AttendanceFilter.absent:
        list = list.where((e) => 
            e.attendance?.status == AppDatabase.statusAbsentExcused || 
            e.attendance?.status == AppDatabase.statusAbsentUnexcused).toList();
        break;
      case AttendanceFilter.all:
        break;
    }
    
    // 2. Lọc theo tên tìm kiếm
    if (searchQuery.value.isNotEmpty) {
      list = list.where((s) => s.student.name.toLowerCase().contains(searchQuery.value.toLowerCase())).toList();
    }
    
    return list;
  }

  @override
  void onInit() {
    super.onInit();
    // Load trạng thái tháng hiện tại ngay khi vào module
    fetchMonthlyStatus(selectedDate.value);
  }

  @override
  void onClose() {
    calendarController.dispose();
    super.onClose();
  }

  // --- LOGIC METHODS ---

  // 1. Xử lý Lịch
  void onDateSelected(DateTime date) {
    selectedDate.value = date;
  }

  DateTime? _lastFetchedMonth;

  void onMonthChanged(DateTime month) {
    // Chỉ fetch nếu tháng hoặc năm thay đổi để tránh gọi API liên tục
    if (_lastFetchedMonth?.year == month.year && 
        _lastFetchedMonth?.month == month.month) {
      return;
    }
    
    _lastFetchedMonth = month;
    // Đưa việc cập nhật vào Future.delayed để tránh lỗi "setState() during build"
    Future.delayed(Duration.zero, () {
      fetchMonthlyStatus(month);
    });
  }

  // Lấy dữ liệu tô màu cho lịch (Xanh/Đỏ)
  Future<void> fetchMonthlyStatus(DateTime month) async {
    if (currentClassId.isEmpty) return;
    try {
      final statusMap = await repository.getMonthlyStatus(currentClassId, month);
      // Sử dụng assignAll để đảm bảo RxMap thông báo cho các observer (Obx) chính xác nhất
      monthlyStatus.assignAll(statusMap);
    } catch (e) {
      debugPrint("Error fetching monthly status: $e");
    }
  }

  // 2. Xử lý Danh sách Điểm danh
  Future<void> fetchAttendanceList() async {
    if (currentClassId.isEmpty) {
      print("DEBUG: Classroom ID đang bị RỖNG! Vui lòng kiểm tra bảng classrooms.");
      AppDialogs.error(message: AppStrings.attendanceNoClass);
      isLoading.value = false;
      return;
    }
  
    isLoading.value = true;
    try {
      final result = await repository.getDailyAttendance(currentClassId, selectedDate.value);
      studentsWithAttendance.assignAll(result);
      hasChanges.value = false;
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isLoading.value = false;
    }
  }

  void toggleEditMode() {
    isEditMode.value = !isEditMode.value;
    if (!isEditMode.value) {
      fetchAttendanceList(); // Reset data nếu hủy bỏ sửa
    }
  }

  // Cập nhật trạng thái local
  void updateStatus(int index, String status) {
    if (isFuture) return; // Không cho phép điểm danh ngày tương lai
    
    // 1. Lấy dữ liệu hiện tại của học sinh này
    var item = studentsWithAttendance[index];
    final currentAttendance = item.attendance;

    // 2. Kiểm tra quyền sửa (Chặn nếu là đơn nghỉ phép từ phụ huynh)
    if (currentAttendance?.status == AppDatabase.statusAbsentExcused && currentAttendance?.method != AppDatabase.methodManual) {
      AppDialogs.warning(message: AppStrings.attendanceStatusConflict);
      return;
    }

    // 3. Logic xử lý giờ đến (Check-in time)
    String? currentTime;
    if (status == AppDatabase.statusPresent) {
      // Chỉ gán giờ hiện tại nếu đang điểm danh cho NGÀY HÔM NAY
      if (isToday) {
        currentTime = DateFormat('HH:mm:ss').format(DateTime.now());
      } else {
        // Ngày cũ thì không gán giờ tự động (hoặc giữ nguyên nếu có)
        currentTime = currentAttendance?.checkinTime;
      }
    } else {
      currentTime = null;
    }

    // 5. Cập nhật Model 
    // Giữ existingId ở mức Controller để UI/State biết đây là record cũ
    // Nhưng khi lưu xuống DB sẽ xử lý riêng để tránh lỗi Batch Inconsistency
    item.attendance = AttendanceModel(
      id: currentAttendance?.id, 
      studentId: item.student.id,
      date: selectedDate.value.toIso8601String().split('T')[0],
      status: status,
      method: AppDatabase.methodManual, 
      checkinTime: currentTime,
      classroomId: currentClassId, 
      teacherId: AuthService.to.currentUser.value?.id,
    );
  
    // 6. Cập nhật giao diện
    studentsWithAttendance[index] = item;
    studentsWithAttendance.refresh(); 
    hasChanges.value = true;
  }

  // Chọn nhanh tất cả đi học
  void markAllPresent() {
    if (isFuture) return; // Không cho phép điểm danh ngày tương lai
    
    for (var i = 0; i < studentsWithAttendance.length; i++) {
      // Chỉ update những bé chưa có trạng thái hoặc đang vắng (ko đụng vào vắng có phép)
      if (studentsWithAttendance[i].attendance?.status != AppDatabase.statusAbsentExcused) {
        updateStatus(i, AppDatabase.statusPresent);
      }
    }
  }

  // 3. Lưu dữ liệu
  Future<void> submitAttendance() async {
    if (isFuture) {
      AppDialogs.warning(message: AppStrings.attendanceFutureWarning);
      return;
    }

    // Hiển thị thoại xác nhận trước khi lưu
    final isConfirmed = await AppDialogs.showConfirm(
      message: AppStrings.dialogSaveMessage,
    );
    if (!isConfirmed) return;

    isLoading.value = true;
    try {
      final listToSave = studentsWithAttendance
          .where((e) => e.attendance != null)
          .map((e) => e.attendance!)
          .toList();

      if (listToSave.isEmpty) {
        AppDialogs.warning(message: AppStrings.attendanceNoSelection);
        return;
      }

      await repository.saveAttendanceBatch(listToSave);
      
      hasChanges.value = false;
      // Refresh lại màu sắc trên lịch sau khi lưu
      await fetchMonthlyStatus(selectedDate.value);
      
      Get.back();
      AppDialogs.success(message: AppStrings.attendanceSuccess);
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isLoading.value = false;
    }
  }

  // --- NAVIGATION ---
  
  Future<void> goToAttendance() async {
    if (currentClassId.isEmpty) {
      AppDialogs.warning(message: AppStrings.attendanceNoClass);
      return;
    }
    await fetchAttendanceList(); 
    Get.toNamed(Routes.ATTENDANCE_LIST);
  }

  Future<void> goToHistory() async {
    if (currentClassId.isEmpty) {
      AppDialogs.warning(message: AppStrings.attendanceNoClass);
      return;
    }
    isEditMode.value = false; // Luôn vào chế độ xem trước
    await fetchAttendanceList();
    Get.toNamed(Routes.ATTENDANCE_HISTORY);
  }

  Future<void> goToStatistics() async {
    if (currentClassId.isEmpty) {
      AppDialogs.warning(message: AppStrings.attendanceNoClass);
      return;
    }
    Get.toNamed(Routes.ATTENDANCE_STATISTIC);
  }
}