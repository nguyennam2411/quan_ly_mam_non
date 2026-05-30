import 'package:get/get.dart';
import '../../../../data/models/qr_token_model.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/repositories/qr_token_repository.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/services/parent_student_service.dart';

class StudentQrController extends GetxController {
  final QrRepository repository;
  
  StudentQrController({required this.repository});

  final isLoading = false.obs;
  final qrToken = Rxn<QrTokenModel>();
  final student = Rxn<StudentModel>();
  late String studentId;

  @override
  void onInit() {
    super.onInit();
    // Lấy studentId từ arguments (truyền từ Home sang)
    if (Get.arguments is String) {
      studentId = Get.arguments;
      // Lấy thông tin bé từ service
      student.value = ParentStudentService.to.students.firstWhereOrNull((s) => s.id == studentId);
      fetchQrToken();
    } else {
      Get.back();
      AppDialogs.error(message: 'Không tìm thấy thông tin học sinh');
    }
  }

  Future<void> fetchQrToken() async {
    try {
      isLoading.value = true;
      final result = await repository.getOrGenerateQrToken(studentId);
      qrToken.value = result;
    } catch (e) {
      AppDialogs.error(message: 'Lỗi khi lấy mã QR: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  // Hàm để làm mới mã nếu cần (sau này có thể mở rộng)
  void refreshQr() {
    fetchQrToken();
  }
}
