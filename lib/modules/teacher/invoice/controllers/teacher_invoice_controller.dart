import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_database.dart';
import '../../../../data/models/invoice_model.dart';
import '../../../../data/repositories/invoice_repository.dart';

class TeacherInvoiceController extends GetxController {
  final InvoiceRepository repository;

  TeacherInvoiceController({required this.repository});

  var isLoading = false.obs;
  var allInvoices = <InvoiceModel>[].obs;
  
  // Mặc định lấy tháng và năm hiện tại
  var currentMonth = DateTime.now().month.obs;
  var currentYear = DateTime.now().year.obs;

  @override
  void onInit() {
    super.onInit();
    fetchInvoices();
  }

  Future<void> fetchInvoices() async {
    isLoading.value = true;
    try {
      final classroomId = AuthService.to.classroomId.value;
      if (classroomId != null) {
        final results = await repository.getInvoicesByClassroom(
          classroomId,
          month: currentMonth.value,
          year: currentYear.value,
        );
        allInvoices.assignAll(results);
      }
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách học phí lớp: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsPaid(String invoiceId) async {
    try {
      await repository.updateInvoiceStatus(invoiceId, AppDatabase.invoiceStatusPaid);
      Get.snackbar('Thành công', 'Đã xác nhận thu tiền thành công!');
      // Refresh list
      fetchInvoices();
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể cập nhật trạng thái: $e');
    }
  }

  void previousMonth() {
    if (currentMonth.value == 1) {
      currentMonth.value = 12;
      currentYear.value--;
    } else {
      currentMonth.value--;
    }
    fetchInvoices();
  }

  void nextMonth() {
    if (currentMonth.value == 12) {
      currentMonth.value = 1;
      currentYear.value++;
    } else {
      currentMonth.value++;
    }
    fetchInvoices();
  }

  // Thuật toán phát hành hoá đơn
  Future<void> generateInvoices() async {
    final classroomId = AuthService.to.classroomId.value;
    if (classroomId == null) return;

    // 1. Kiểm tra xem tháng này đã phát hành chưa
    if (allInvoices.isNotEmpty) {
      Get.snackbar('Thông báo', 'Tháng này đã phát hành hoá đơn rồi!');
      return;
    }

    isLoading.value = true;
    try {
      // 2. Lấy danh sách học sinh
      final studentsData = await repository.getStudentsByClassroom(classroomId);
      
      // 3. Chuẩn bị mốc thời gian của tháng trước để tính ngày nghỉ
      final previousMonth = currentMonth.value == 1 ? 12 : currentMonth.value - 1;
      final previousYear = currentMonth.value == 1 ? currentYear.value - 1 : currentYear.value;
      
      final startDate = DateTime(previousYear, previousMonth, 1).toIso8601String().substring(0, 10);
      // Ngày cuối tháng trước (Lấy ngày 1 tháng này lùi lại 1 ngày)
      final endDate = DateTime(currentYear.value, currentMonth.value, 1).subtract(const Duration(days: 1)).toIso8601String().substring(0, 10);

      List<InvoiceModel> newInvoices = [];

      // 4. Lặp qua từng học sinh để tính tiền
      for (var s in studentsData) {
        final studentId = s[AppDatabase.colId];
        
        // Đếm ngày nghỉ có phép tháng trước
        final absentDays = await repository.countExcusedAbsences(studentId, startDate, endDate);
        
        double total = 0.0;
        List<InvoiceItemModel> items = [];

        // Nhóm A: Phí cố định
        items.add(InvoiceItemModel(group: 'A', type: 'fixed', name: 'Học phí chính khoá', amount: AppConstants.baseFixedFee));
        total += AppConstants.baseFixedFee;
        items.add(InvoiceItemModel(group: 'A', type: 'fixed', name: 'Phí vệ sinh & Nước uống', amount: AppConstants.baseSanitationFee));
        total += AppConstants.baseSanitationFee;

        // Nhóm B: Tiền ăn tháng mới
        final mealFee = AppConstants.baseDailyMealFee * AppConstants.expectedSchoolDays;
        items.add(InvoiceItemModel(
          group: 'B', type: 'meal', 
          name: 'Tiền ăn tháng ${currentMonth.value} (${AppConstants.expectedSchoolDays} ngày)', 
          amount: mealFee, 
          days: AppConstants.expectedSchoolDays, 
          unitPrice: AppConstants.baseDailyMealFee
        ));
        total += mealFee;

        // Nhóm D: Bù trừ tiền ăn do nghỉ có phép tháng trước
        if (absentDays > 0) {
          final refund = absentDays * AppConstants.baseDailyMealFee;
          items.add(InvoiceItemModel(
            group: 'D', type: 'refund', 
            name: 'Hoàn tiền ăn vắng có phép tháng $previousMonth', 
            amount: -refund.toDouble(), // Số âm
            absentDays: absentDays
          ));
          total -= refund;
        }

        // Tạo Model hoá đơn
        final invoice = InvoiceModel(
          studentId: studentId,
          month: currentMonth.value,
          year: currentYear.value,
          totalAmount: total,
          status: AppDatabase.invoiceStatusUnpaid,
          dueDate: DateTime(currentYear.value, currentMonth.value, 10), // Hạn chót mùng 10
          items: items,
        );

        newInvoices.add(invoice);
      }

      // 5. Đẩy hàng loạt lên Database
      if (newInvoices.isNotEmpty) {
        await repository.insertInvoices(newInvoices);
        Get.snackbar('Thành công', 'Đã phát hành ${newInvoices.length} hoá đơn!');
        fetchInvoices();
      }
      
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể phát hành hoá đơn: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
