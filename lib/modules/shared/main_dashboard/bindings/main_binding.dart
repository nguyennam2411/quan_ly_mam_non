import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/values/user_role.dart';
import '../../../../data/providers/student_provider.dart';
import '../../../../data/repositories/student_repository.dart';
import '../../../../data/providers/notification_provider.dart';
import '../../../../data/repositories/notification_repository.dart';
import '../../notifications/controllers/notification_controller.dart';
import '../../../teacher/teacher_home/controllers/teacher_home_controller.dart';
import '../../../../data/repositories/attendance_repository.dart';
import '../controllers/main_controller.dart';

class MainBinding extends Bindings {
  @override
  void dependencies() {
    // MainController giữ trạng thái chung của Dashboard
    Get.lazyPut<MainController>(() => MainController(), fenix: true);

    // Nếu người dùng là phụ huynh, khởi tạo ParentStudentService để quản lý học sinh
    if (UserRole.isParent(AuthService.to.userRole.value)) {
      final studentProvider = StudentProvider();
      final studentRepository = StudentRepository(studentProvider);
      
      Get.put<ParentStudentService>(
        ParentStudentService(studentRepository),
        permanent: true,
      );
    }

    // Luôn nạp NotificationController để nhận thông báo realtime và hiện Badge
    Get.lazyPut(() => NotificationProvider());
    Get.lazyPut(() => NotificationRepository());
    Get.put(NotificationController());

    // Nếu người dùng là giáo viên, khởi tạo TeacherHomeController
    if (UserRole.isTeacher(AuthService.to.userRole.value)) {
      Get.lazyPut<TeacherHomeController>(() => TeacherHomeController(
        StudentRepository(StudentProvider()),
        AttendanceRepository(),
      ));
    }
  }
}