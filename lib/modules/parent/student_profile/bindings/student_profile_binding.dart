import 'package:get/get.dart';
import '../../../../data/providers/health_record_provider.dart';
import '../../../../data/repositories/health_record_repository.dart';
import '../../../../data/providers/student_guardian_provider.dart';
import '../../../../data/repositories/student_guardian_repository.dart';
import '../../../../data/providers/student_provider.dart';
import '../../../../data/repositories/student_repository.dart';
import '../controllers/student_profile_controller.dart';

class StudentProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<HealthRecordRepository>(
      () => HealthRecordRepository(provider: HealthRecordProvider()),
    );
    Get.lazyPut<StudentGuardianRepository>(
      () => StudentGuardianRepository(StudentGuardianProvider()),
    );
    Get.lazyPut<StudentRepository>(
      () => StudentRepository(StudentProvider()),
    );
    Get.lazyPut<StudentProfileController>(
      () => StudentProfileController(
        healthRepository: Get.find<HealthRecordRepository>(),
        guardianRepository: Get.find<StudentGuardianRepository>(),
        studentRepository: Get.find<StudentRepository>(),
      ),
    );
  }
}
