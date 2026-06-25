import 'package:get/get.dart';
import '../../../../data/repositories/medication_repository.dart';
import '../controllers/teacher_medication_request_controller.dart';

class TeacherMedicationRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MedicationRepository>(() => MedicationRepository());
    Get.lazyPut<TeacherMedicationRequestController>(() => TeacherMedicationRequestController(repository: Get.find()));
  }
}
