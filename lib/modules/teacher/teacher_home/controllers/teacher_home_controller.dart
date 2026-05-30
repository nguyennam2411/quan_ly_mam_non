import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/values/app_database.dart';
import '../../../../data/repositories/attendance_repository.dart';
import '../../../../data/repositories/student_repository.dart';

class TeacherHomeController extends GetxController {
  final StudentRepository _studentRepository;
  final AttendanceRepository _attendanceRepository;

  TeacherHomeController(this._studentRepository, this._attendanceRepository);

  final RxInt totalStudents = 0.obs;
  final RxInt presentStudents = 0.obs;
  final RxBool isLoading = false.obs;

  String get classroomName => AuthService.to.classroomName.value;
  String get classroomId => AuthService.to.classroomId.value;

  @override
  void onInit() {
    super.onInit();
    fetchClassroomStats();
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
      print('Error fetching classroom stats: $e');
    } finally {
      isLoading.value = false;
    }
  }

  double get attendancePercentage {
    if (totalStudents.value == 0) return 0;
    return (presentStudents.value / totalStudents.value);
  }
}
