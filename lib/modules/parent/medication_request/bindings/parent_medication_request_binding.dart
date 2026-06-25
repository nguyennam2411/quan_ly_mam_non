import 'package:get/get.dart';
import '../../../../data/repositories/medication_repository.dart';
import '../controllers/parent_medication_request_controller.dart';

class ParentMedicationRequestBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<MedicationRepository>(() => MedicationRepository());
    Get.lazyPut<ParentMedicationRequestController>(() => ParentMedicationRequestController());
  }
}
