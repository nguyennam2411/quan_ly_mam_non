import 'package:get/get.dart';
import '../../../../data/providers/student_provider.dart';
import '../../../../data/providers/student_guardian_provider.dart';
import '../../../../data/repositories/student_repository.dart';
import '../../../../data/repositories/student_guardian_repository.dart';
import '../controllers/teacher_classroom_controller.dart';

class TeacherClassroomBinding extends Bindings {
  @override
  void dependencies() {
    // 1. Quản lý danh sách lớp học
    Get.lazyPut(() => StudentProvider());
    Get.lazyPut(() => StudentRepository(Get.find<StudentProvider>()));
    Get.lazyPut(() => TeacherClassroomController(
          studentRepository: Get.find<StudentRepository>(),
        ));

    // 2. Quản lý chi tiết học sinh & liên hệ người giám hộ
    Get.lazyPut(() => StudentGuardianProvider());
    Get.lazyPut(() => StudentGuardianRepository(Get.find<StudentGuardianProvider>()));
    Get.lazyPut(() => TeacherStudentDetailController(
          guardianRepository: Get.find<StudentGuardianRepository>(),
        ));
  }
}
