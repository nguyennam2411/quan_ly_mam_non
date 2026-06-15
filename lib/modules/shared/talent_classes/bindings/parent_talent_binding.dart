import 'package:get/get.dart';
import '../controllers/parent_talent_controller.dart';

class ParentTalentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ParentTalentController>(() => ParentTalentController());
  }
}
