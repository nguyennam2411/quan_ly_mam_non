import 'package:get/get.dart';
import '../controllers/teacher_talent_controller.dart';

class TeacherTalentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TeacherTalentController>(() => TeacherTalentController());
  }
}
