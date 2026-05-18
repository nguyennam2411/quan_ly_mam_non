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
        .order(AppDatabase.colMonth, ascending: false)
        .order(AppDatabase.colYear, ascending: false);
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
        .eq(AppDatabase.colStatus, AppDatabase.invoiceStatusUnpaid);
  }

  // Giáo viên/Kế toán: Cập nhật trạng thái hoá đơn
  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    await _client
        .from(AppDatabase.tableInvoices)
        .update({AppDatabase.colStatus: status})
        .eq(AppDatabase.colId, invoiceId);
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
