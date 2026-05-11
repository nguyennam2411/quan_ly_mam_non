import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_database.dart';
import '../../../../data/models/invoice_model.dart';
import '../../../../data/models/payment_model.dart';
import '../../../../data/repositories/invoice_repository.dart';
import '../views/parent_payment_gateway_view.dart';

class ParentInvoiceController extends GetxController {
  final InvoiceRepository repository;

  ParentInvoiceController({required this.repository});

  var isLoading = false.obs;
  var allInvoices = <InvoiceModel>[].obs;
  var selectedStatus = 'ALL'.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInvoices();

    // Lắng nghe nếu phụ huynh đổi bé khác (trong trường hợp có 2 con)
    ever(ParentStudentService.to.selectedStudent, (_) {
      fetchInvoices();
    });
  }

  List<InvoiceModel> get filteredInvoices {
    final currentStudent = ParentStudentService.to.selectedStudent.value;
    
    return allInvoices.where((invoice) {
      // 1. Lọc theo học sinh đang được chọn
      if (currentStudent != null && invoice.studentId != currentStudent.id) {
        return false;
      }
      
      // 2. Lọc theo trạng thái thanh toán
      if (selectedStatus.value != 'ALL') {
        if (invoice.status != selectedStatus.value) return false;
      }
      
      return true;
    }).toList();
  }

  Future<void> fetchInvoices() async {
    isLoading.value = true;
    try {
      final parentId = AuthService.to.currentUser.value?.id;
      if (parentId != null) {
        final results = await repository.getInvoicesByParent(parentId);
        allInvoices.assignAll(results);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách học phí: $e');
    } finally {
      isLoading.value = false;
    }
  }

  // Mở cổng thanh toán mô phỏng
  void simulatePayment(InvoiceModel invoice) {
    Get.to(() => ParentPaymentGatewayView(invoice: invoice));
  }

  // Xác nhận thanh toán thành công
  Future<void> confirmPayment(InvoiceModel invoice) async {
    final invoiceId = invoice.id;
    if (invoiceId == null) return;

    isLoading.value = true;
    try {
      // 1. Cập nhật trạng thái hoá đơn thành Chờ xác nhận
      await repository.updateInvoiceStatus(invoiceId, AppDatabase.pending);

      // 2. Lưu biên lai vào bảng payments
      final payment = PaymentModel(
        invoiceId: invoiceId,
        method: 'BANK_TRANSFER',
        amount: invoice.totalAmount,
        paidAt: DateTime.now(),
      );
      await repository.insertPayment(payment);

      // 3. Thông báo và làm mới
      Get.back(); // Đóng màn hình thanh toán
      Get.snackbar('Thành công', 'Cảm ơn bạn đã thanh toán học phí! 🎉',
          backgroundColor: AppColors.success.withValues(alpha: 0.1),
          colorText: AppColors.success);
      
      fetchInvoices();
    } catch (e) {
      Get.snackbar('Lỗi', 'Giao dịch thất bại: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
