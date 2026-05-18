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
  
  // Lọc: ALL, PAID, UNPAID, DEBT
  var selectedFilter = 'ALL'.obs;

  List<InvoiceModel> get filteredInvoices {
    if (selectedFilter.value == 'PAID') {
      return allInvoices.where((i) => i.status == AppDatabase.invoiceStatusPaid).toList();
    }
    if (selectedFilter.value == 'UNPAID') {
      return allInvoices.where((i) => i.status == AppDatabase.invoiceStatusUnpaid || i.status == AppDatabase.pending).toList();
    }
    if (selectedFilter.value == 'DEBT') {
      return allInvoices.where((i) => i.status == AppDatabase.invoiceStatusOverdue).toList();
    }
    return allInvoices;
  }

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

        // Nhóm A: Phí cố định và các môn học
        final fixedFees = [
          {'name': 'Học phí', 'amount': 1020000.0},
          {'name': 'K.phí XH hóa P.vụ bữa ăn', 'amount': 700000.0},
          {'name': 'Điện nước', 'amount': 65000.0},
          {'name': 'Vệ sinh phí', 'amount': 38000.0},
          {'name': 'Anh văn', 'amount': 100000.0},
          {'name': 'Vẽ', 'amount': 90000.0},
          {'name': 'Bóng đá', 'amount': 90000.0},
        ];

        for (var fee in fixedFees) {
          items.add(InvoiceItemModel(group: 'A', type: 'fixed', name: fee['name'] as String, amount: fee['amount'] as double));
          total += fee['amount'] as double;
        }

        // Nhóm B: Tiền ăn tháng mới (Tính số ngày đi học thực tế trong tháng)
        final mealDays = _calculateSchoolDays(currentYear.value, currentMonth.value);
        final mealNormal = 38000.0;
        final mealBreakfast = 18000.0;
        
        items.add(InvoiceItemModel(
          group: 'B', type: 'meal', 
          name: 'Tiền ăn BT (${mealNormal.toInt()}đ x $mealDays)', 
          amount: mealNormal * mealDays, 
        ));
        total += mealNormal * mealDays;

        items.add(InvoiceItemModel(
          group: 'B', type: 'meal', 
          name: 'Tiền ăn sáng (${mealBreakfast.toInt()}đ x $mealDays)', 
          amount: mealBreakfast * mealDays, 
        ));
        total += mealBreakfast * mealDays;

        // Nhóm D: Bù trừ tiền ăn do nghỉ có phép tháng trước
        if (absentDays > 0) {
          final refund = absentDays * (mealNormal + mealBreakfast); // Trả lại cả tiền ăn trưa và ăn sáng
          items.add(InvoiceItemModel(
            group: 'D', type: 'refund', 
            name: 'Tiền thừa T.$previousMonth (Vắng $absentDays ngày)', 
            amount: -refund.toDouble(), // Số âm
            absentDays: absentDays
          ));
          total -= refund;
        }

        // Nhóm E: Nợ cũ chuyển sang (OVERDUE)
        final unpaidInvoices = await repository.getUnpaidInvoicesByStudent(studentId as String);
        for (var oldInvoice in unpaidInvoices) {
          // Bỏ qua hoá đơn của chính tháng đang phát hành (nếu có lỗi trùng lặp)
          if (oldInvoice.month == currentMonth.value && oldInvoice.year == currentYear.value) continue;
          
          items.add(InvoiceItemModel(
            group: 'E', type: 'debt', 
            name: 'Nợ học phí T.${oldInvoice.month}/${oldInvoice.year}', 
            amount: oldInvoice.totalAmount, 
          ));
          total += oldInvoice.totalAmount;
          
          // Chuyển hoá đơn cũ sang trạng thái QUÁ HẠN
          if (oldInvoice.id != null) {
            await repository.updateInvoiceStatus(oldInvoice.id!, AppDatabase.invoiceStatusOverdue);
          }
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
  // Hàm đếm số ngày đi học (Thứ 2 - Thứ 6) trong tháng
  int _calculateSchoolDays(int year, int month) {
    int daysInMonth = DateTime(year, month + 1, 0).day;
    int schoolDays = 0;
    for (int i = 1; i <= daysInMonth; i++) {
      DateTime date = DateTime(year, month, i);
      if (date.weekday != DateTime.saturday && date.weekday != DateTime.sunday) {
        schoolDays++;
      }
    }
    return schoolDays;
  }
}
