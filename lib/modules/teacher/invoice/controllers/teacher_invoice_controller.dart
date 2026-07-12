import 'package:get/get.dart';
import '../../../../core/services/auth_service.dart';
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
      final results = await repository.getInvoicesByClassroom(
        classroomId,
        month: currentMonth.value,
        year: currentYear.value,
      );
      allInvoices.assignAll(results);
        } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách học phí lớp: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> markAsPaid(String invoiceId) async {
    try {
      // 1. Cập nhật hoá đơn hiện tại
      await repository.updateInvoiceStatus(invoiceId, AppDatabase.invoiceStatusPaid);
      
      // 2. Tìm học sinh của hoá đơn này
      final invoice = allInvoices.firstWhereOrNull((i) => i.id == invoiceId);
      if (invoice != null) {
        // 3. Lấy tất cả hoá đơn nợ cũ và tự động gạch nợ (vì đã thu gộp)
        final unpaidInvoices = await repository.getUnpaidInvoicesByStudent(invoice.studentId);
        for (var old in unpaidInvoices) {
          if (old.status == AppDatabase.invoiceStatusOverdue && old.id != null && old.id != invoiceId) {
            await repository.updateInvoiceStatus(old.id!, AppDatabase.invoiceStatusPaid);
          }
        }
      }

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

  Future<void> generateInvoices() async {
    final classroomId = AuthService.to.classroomId.value;

    // 1. Kiểm tra xem tháng này đã phát hành chưa
    if (allInvoices.isNotEmpty) {
      Get.snackbar('Thông báo', 'Tháng này đã phát hành hoá đơn rồi!');
      return;
    }

    isLoading.value = true;
    try {
      // 2. Lấy danh sách học sinh
      final studentsData = await repository.getStudentsByClassroom(classroomId);
      
      // 3. Chuẩn bị mốc thời gian của tháng này (để đếm ngày nghỉ và điểm danh trực tiếp trong tháng)
      final startDate = DateTime(currentYear.value, currentMonth.value, 1).toIso8601String().substring(0, 10);
      final endDate = DateTime(currentYear.value, currentMonth.value + 1, 0).toIso8601String().substring(0, 10);

      // Tổng số ngày đi học (Thứ 2 - Thứ 6) dự kiến của cả tháng
      final mealDays = _calculateSchoolDays(currentYear.value, currentMonth.value);

      // Lấy song song dữ liệu vắng mặt và hóa đơn chưa thanh toán cho tất cả học sinh để tối ưu hiệu năng (Fix N+1 query)
      final List<String> studentIds = studentsData.map((s) => s[AppDatabase.colId] as String).toList();
      
      final absentDaysResults = await Future.wait(
        studentIds.map((id) => repository.countExcusedAbsences(id, startDate, endDate))
      );
      
      final unpaidInvoicesResults = await Future.wait(
        studentIds.map((id) => repository.getUnpaidInvoicesByStudent(id))
      );

      List<InvoiceModel> newInvoices = [];
      List<Future<void>> updateStatusFutures = [];

      // 4. Lặp qua từng học sinh để tính tiền
      for (int i = 0; i < studentsData.length; i++) {
        final studentId = studentIds[i];
        final absentDays = absentDaysResults[i];
        final unpaidInvoices = unpaidInvoicesResults[i];
        
        double total = 0.0;
        List<InvoiceItemModel> items = [];

        // Nhóm A: Phí cố định và các môn học (Luôn thu 100% cố định theo tháng, không chia theo ngày)
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
          final feeAmount = fee['amount'] as double;
          items.add(InvoiceItemModel(
            group: 'A', 
            type: 'fixed', 
            name: fee['name'] as String, 
            amount: feeAmount,
          ));
          total += feeAmount;
        }

        // Nhóm B: Tiền ăn (Tính đúng theo số ngày thực tế trừ đi ngày nghỉ phép)
        final mealNormal = 38000.0;
        final mealBreakfast = 18000.0;
        
        // Số ngày ăn thực tế = Tổng số ngày học trong tháng - Số ngày nghỉ phép
        final attendedDays = (mealDays - absentDays) < 0 ? 0 : (mealDays - absentDays);
        
        items.add(InvoiceItemModel(
          group: 'B', type: 'meal', 
          name: 'Tiền ăn BT (${mealNormal.toInt()}đ x $attendedDays ngày)', 
          amount: mealNormal * attendedDays, 
        ));
        total += mealNormal * attendedDays;

        items.add(InvoiceItemModel(
          group: 'B', type: 'meal', 
          name: 'Tiền ăn sáng (${mealBreakfast.toInt()}đ x $attendedDays ngày)', 
          amount: mealBreakfast * attendedDays, 
        ));
        total += mealBreakfast * attendedDays;

        // Nhóm E: Nợ cũ chuyển sang (OVERDUE)
        for (var oldInvoice in unpaidInvoices) {
          if (oldInvoice.month == currentMonth.value && oldInvoice.year == currentYear.value) continue;
          
          items.add(InvoiceItemModel(
            group: 'E', type: 'debt', 
            name: 'Nợ học phí T.${oldInvoice.month}/${oldInvoice.year}', 
            amount: oldInvoice.totalAmount, 
          ));
          total += oldInvoice.totalAmount;
          
          if (oldInvoice.id != null) {
            updateStatusFutures.add(repository.updateInvoiceStatus(oldInvoice.id!, AppDatabase.invoiceStatusOverdue));
          }
        }

        // Tính ngày hạn chót đóng là mùng 10 của tháng kế tiếp
        int dueMonth = currentMonth.value + 1;
        int dueYear = currentYear.value;
        if (dueMonth > 12) {
          dueMonth = 1;
          dueYear += 1;
        }
        final dueDate = DateTime(dueYear, dueMonth, 10);

        // Tạo Model hoá đơn
        final invoice = InvoiceModel(
          studentId: studentId,
          month: currentMonth.value,
          year: currentYear.value,
          totalAmount: total,
          status: AppDatabase.invoiceStatusUnpaid,
          dueDate: dueDate,
          items: items,
        );

        newInvoices.add(invoice);
      }

      // Cập nhật song song trạng thái các hoá đơn cũ
      if (updateStatusFutures.isNotEmpty) {
        await Future.wait(updateStatusFutures);
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
