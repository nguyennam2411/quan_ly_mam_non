import 'package:get/get.dart';
import '../../../../data/models/talent_class_model.dart';
import '../../../../data/models/talent_enrollment_model.dart';
import '../../../../data/repositories/talent_repository.dart';

import '../../../../data/providers/invoice_provider.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/values/app_database.dart';

class ParentTalentController extends GetxController {
  final TalentRepository _repository = TalentRepository();
  final InvoiceProvider _invoiceProvider = InvoiceProvider();

  final RxList<TalentClassModel> availableClasses = <TalentClassModel>[].obs;
  final RxList<TalentEnrollmentModel> myEnrollments = <TalentEnrollmentModel>[].obs;
  final RxBool isLoading = true.obs;

  String get currentStudentId {
    final student = ParentStudentService.to.selectedStudent.value;
    return student?.id ?? '';
  }

  @override
  void onInit() {
    super.onInit();
    fetchData();
    ever(ParentStudentService.to.selectedStudent, (_) => fetchData());
  }

  Future<void> fetchData() async {
    try {
      isLoading.value = true;
      // Fetch all classes
      final classes = await _repository.getAllTalentClasses();
      availableClasses.assignAll(classes.where((c) => c.status == AppDatabase.statusActive).toList());

      // Fetch my enrollments
      final enrollments = await _repository.getEnrollmentsByStudents([currentStudentId]);
      myEnrollments.assignAll(enrollments);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải dữ liệu lớp năng khiếu');
    } finally {
      isLoading.value = false;
    }
  }

  bool isEnrolled(String classId) {
    return myEnrollments.any((e) => e.talentClassId == classId && e.status != 'CANCELLED');
  }

  Future<void> enrollInClass(TalentClassModel talentClass) async {
    try {
      isLoading.value = true;
      final enrollment = TalentEnrollmentModel(
        studentId: currentStudentId,
        talentClassId: talentClass.id!,
        status: 'APPROVED',
      );
      
      await _repository.submitEnrollment(enrollment);
      
      // LÍ TƯỞNG: Kích hoạt logic cộng tiền vào Học phí (Tuition)
      await _invoiceProvider.addTalentFeeToCurrentInvoice(currentStudentId, talentClass.name, talentClass.feePerMonth);

      Get.snackbar(
        'Đăng ký thành công', 
        'Học phí ${talentClass.feePerMonth}đ đã được cộng vào Hóa đơn tháng!',
        duration: const Duration(seconds: 4),
      );
      
      await fetchData(); // Refresh data
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể đăng ký: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> cancelEnrollment(TalentClassModel talentClass) async {
    try {
      isLoading.value = true;
      final enrollment = TalentEnrollmentModel(
        studentId: currentStudentId,
        talentClassId: talentClass.id!,
        status: 'CANCELLED',
      );
      
      await _repository.submitEnrollment(enrollment);
      
      // LÍ TƯỞNG: Kích hoạt logic trừ tiền khỏi Học phí (Tuition)
      await _invoiceProvider.removeTalentFeeFromCurrentInvoice(currentStudentId, talentClass.name, talentClass.feePerMonth);

      Get.snackbar('Thành công', 'Đã hủy đăng ký môn ${talentClass.name}. Học phí đã được tự động trừ đi.');
      
      await fetchData(); // Refresh data
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể hủy đăng ký: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
