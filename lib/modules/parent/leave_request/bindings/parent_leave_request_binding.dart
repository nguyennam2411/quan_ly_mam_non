import 'package:get/get.dart';
import '../../../../data/providers/leave_request_provider.dart';
import '../../../../data/repositories/leave_request_repository.dart';
import '../controllers/parent_leave_request_controller.dart';

class ParentLeaveRequestBinding extends Bindings {
  @override
  void dependencies() {
    // Khởi tạo Provider & Repository
    Get.lazyPut(() => LeaveRequestProvider());
    Get.lazyPut(() => LeaveRequestRepository());
    
    // Khởi tạo Controller
    Get.lazyPut(() => ParentLeaveRequestController());
  }
}