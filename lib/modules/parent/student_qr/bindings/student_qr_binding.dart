import 'package:get/get.dart';
import '../controllers/student_qr_controller.dart';
import '../../../../data/repositories/qr_token_repository.dart';

class StudentQrBinding extends Bindings {
  @override
  void dependencies() {
    // Inject Repository nếu chưa có global
    Get.lazyPut<QrRepository>(() => QrRepository());
    
    // Inject Controller
    Get.lazyPut<StudentQrController>(
      () => StudentQrController(repository: Get.find<QrRepository>()),
    );
  }
}
