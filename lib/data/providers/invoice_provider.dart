import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../core/values/app_database.dart';

class InvoiceProvider {
  final _client = Supabase.instance.client;

  // Phụ huynh: Lấy danh sách hoá đơn của mình (theo parentId hoặc studentId)
  Future<List<dynamic>> getInvoicesByParent(String parentId) async {
    // Thông thường Invoice sẽ gắn với student_id. 
    // Nếu trong DB không có cột parent_id ở Invoices, 
    // ta phải join qua bảng students để lọc theo parent_id.
    return await _client
        .from(AppDatabase.tableInvoices)
        .select('*, ${AppDatabase.tableStudents}!inner(*, ${AppDatabase.tableClassrooms}(${AppDatabase.colName}))')
        .eq('${AppDatabase.tableStudents}.${AppDatabase.colParentId}', parentId)
        .order(AppDatabase.colYear, ascending: false)
        .order(AppDatabase.colMonth, ascending: false);
  }

  // Lấy chi tiết 1 hoá đơn (Kèm thông tin thanh toán nếu có)
  Future<Map<String, dynamic>> getInvoiceDetails(String invoiceId) async {
    return await _client
        .from(AppDatabase.tableInvoices)
        .select('*, ${AppDatabase.tableStudents}(*, ${AppDatabase.tableClassrooms}(${AppDatabase.colName})), ${AppDatabase.tablePayments}(*)')
        .eq(AppDatabase.colId, invoiceId)
        .single();
  }

  // Giáo viên: Lấy danh sách hoá đơn của lớp
  Future<List<dynamic>> getInvoicesByClassroom(String classroomId, {int? month, int? year}) async {
    var query = _client
        .from(AppDatabase.tableInvoices)
        .select('*, ${AppDatabase.tableStudents}!inner(*)')
        .eq('${AppDatabase.tableStudents}.${AppDatabase.colClassroomId}', classroomId);
        
    if (month != null) query = query.eq(AppDatabase.colMonth, month);
    if (year != null) query = query.eq(AppDatabase.colYear, year);
    
    return await query
        .order(AppDatabase.colCreatedAt, ascending: false);
  }

  // Lấy danh sách hoá đơn chưa đóng của một học sinh
  Future<List<dynamic>> getUnpaidInvoicesByStudent(String studentId) async {
    return await _client
        .from(AppDatabase.tableInvoices)
        .select()
        .eq(AppDatabase.colStudentId, studentId)
        .inFilter(AppDatabase.colStatus, [
          AppDatabase.invoiceStatusUnpaid,
          AppDatabase.invoiceStatusOverdue,
          AppDatabase.pending,
        ]);
  }

  // Giáo viên/Kế toán: Cập nhật trạng thái hoá đơn
  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    await _client
        .from(AppDatabase.tableInvoices)
        .update({AppDatabase.colStatus: status})
        .eq(AppDatabase.colId, invoiceId);
  }

  // Cập nhật hóa đơn khi Phụ huynh đăng ký Năng khiếu
  Future<void> addTalentFeeToCurrentInvoice(String studentId, String className, int fee) async {
    final now = DateTime.now();
    // Tìm hóa đơn chưa thanh toán của tháng hiện tại
    final response = await _client
        .from(AppDatabase.tableInvoices)
        .select()
        .eq(AppDatabase.colStudentId, studentId)
        .eq(AppDatabase.colStatus, AppDatabase.invoiceStatusUnpaid)
        .eq(AppDatabase.colMonth, now.month)
        .eq(AppDatabase.colYear, now.year)
        .maybeSingle();

    if (response != null) {
      List<dynamic> items = List.from(response[AppDatabase.colItems] ?? []);
      double totalAmount = (response[AppDatabase.colTotalAmount] ?? 0).toDouble();

      // Thêm khoản phí năng khiếu
      items.add({
        'group': 'talent',
        'type': 'addition',
        'name': 'Năng khiếu: $className',
        'amount': fee,
      });
      totalAmount += fee;

      // Cập nhật lại hóa đơn
      await _client
          .from(AppDatabase.tableInvoices)
          .update({
            AppDatabase.colItems: items,
            AppDatabase.colTotalAmount: totalAmount,
          })
          .eq(AppDatabase.colId, response[AppDatabase.colId]);
    }
  }

  // Cập nhật hóa đơn khi Phụ huynh HỦY Năng khiếu
  Future<void> removeTalentFeeFromCurrentInvoice(String studentId, String className, int fee) async {
    final now = DateTime.now();
    final response = await _client
        .from(AppDatabase.tableInvoices)
        .select()
        .eq(AppDatabase.colStudentId, studentId)
        .eq(AppDatabase.colStatus, AppDatabase.invoiceStatusUnpaid)
        .eq(AppDatabase.colMonth, now.month)
        .eq(AppDatabase.colYear, now.year)
        .maybeSingle();

    if (response != null) {
      List<dynamic> items = List.from(response[AppDatabase.colItems] ?? []);
      double totalAmount = (response[AppDatabase.colTotalAmount] ?? 0).toDouble();

      final targetName = 'Năng khiếu: $className';
      final itemIndex = items.indexWhere((item) => item['name'] == targetName);

      if (itemIndex != -1) {
        items.removeAt(itemIndex);
        totalAmount -= fee;

        await _client
            .from(AppDatabase.tableInvoices)
            .update({
              AppDatabase.colItems: items,
              AppDatabase.colTotalAmount: totalAmount,
            })
            .eq(AppDatabase.colId, response[AppDatabase.colId]);
      }
    }
  }

  // Lấy tổng số ngày nghỉ có phép của 1 bé trong khoảng thời gian
  Future<int> countExcusedAbsences(String studentId, String startDate, String endDate) async {
    final response = await _client
        .from(AppDatabase.tableAttendance)
        .select(AppDatabase.colId)
        .eq(AppDatabase.colStudentId, studentId)
        .eq(AppDatabase.colStatus, AppDatabase.statusAbsentExcused)
        .gte(AppDatabase.colDate, startDate)
        .lte(AppDatabase.colDate, endDate);
    
    return (response as List).length;
  }

  // Lấy danh sách các ngày điểm danh của 1 bé trong khoảng thời gian để tính thời gian học thực tế
  Future<List<String>> getAttendanceDates(String studentId, String startDate, String endDate) async {
    final response = await _client
        .from(AppDatabase.tableAttendance)
        .select(AppDatabase.colDate)
        .eq(AppDatabase.colStudentId, studentId)
        .gte(AppDatabase.colDate, startDate)
        .lte(AppDatabase.colDate, endDate)
        .order(AppDatabase.colDate, ascending: true);
    
    return (response as List).map((item) => item[AppDatabase.colDate].toString()).toList();
  }

  // Phụ huynh: Ghi nhận thanh toán
  Future<void> insertPayment(Map<String, dynamic> paymentData) async {
    await _client.from(AppDatabase.tablePayments).insert(paymentData);
  }

  // Phát hành hàng loạt hoá đơn
  Future<void> insertInvoices(List<Map<String, dynamic>> invoices) async {
    await _client.from(AppDatabase.tableInvoices).insert(invoices);
  }

  // Lấy danh sách học sinh của một lớp
  Future<List<dynamic>> getStudentsByClassroom(String classroomId) async {
    return await _client
        .from(AppDatabase.tableStudents)
        .select()
        .eq(AppDatabase.colClassroomId, classroomId);
  }
}
