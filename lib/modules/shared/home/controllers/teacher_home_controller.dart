import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/values/app_database.dart';
import '../../../../data/repositories/attendance_repository.dart';
import '../../../../data/repositories/student_repository.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/utils/app_error_message.dart';

class TeacherHomeController extends GetxController {
  final StudentRepository _studentRepository;
  final AttendanceRepository _attendanceRepository;

  TeacherHomeController(this._studentRepository, this._attendanceRepository);

  final RxInt totalStudents = 0.obs;
  final RxInt presentStudents = 0.obs;
  final RxBool isLoading = false.obs;
  final List<Worker> _workers = [];

  String get classroomName => AuthService.to.classroomName.value;
  String get classroomId => AuthService.to.classroomId.value;

  @override
  void onInit() {
    super.onInit();
    if (classroomId.isNotEmpty) {
      fetchClassroomStats();
    }
    _workers.add(ever(AuthService.to.classroomId, (classId) {
      if (classId.isNotEmpty) {
        fetchClassroomStats();
      }
    }));
  }

  Future<void> fetchClassroomStats() async {
    if (classroomId.isEmpty) return;

    try {
      isLoading.value = true;
      
      // 1. Get total students
      final students = await _studentRepository.getStudentsByClassroom(classroomId);
      totalStudents.value = students.length;

      // 2. Get today's attendance
      final attendanceList = await _attendanceRepository.getDailyAttendance(classroomId, DateTime.now());
      presentStudents.value = attendanceList.where((e) => e.attendance?.status == AppDatabase.statusPresent).length;
      
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isLoading.value = false;
    }
  }

  double get attendancePercentage {
    if (totalStudents.value == 0) return 0;
    return (presentStudents.value / totalStudents.value);
  }

  @override
  void onClose() {
    for (var worker in _workers) {
      worker.dispose();
    }
    super.onClose();
  }
}
