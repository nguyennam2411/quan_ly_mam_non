import '../models/invoice_model.dart';
import '../models/payment_model.dart';
import '../providers/invoice_provider.dart';

class InvoiceRepository {
  final InvoiceProvider provider;

  InvoiceRepository({required this.provider});

  Future<List<InvoiceModel>> getInvoicesByParent(String parentId) async {
    final List<dynamic> results = await provider.getInvoicesByParent(parentId);
    return results.map((json) => InvoiceModel.fromJson(json)).toList();
  }

  Future<InvoiceModel> getInvoiceDetails(String invoiceId) async {
    final Map<String, dynamic> result = await provider.getInvoiceDetails(invoiceId);
    return InvoiceModel.fromJson(result);
  }

  Future<List<InvoiceModel>> getInvoicesByClassroom(String classroomId, {int? month, int? year}) async {
    final List<dynamic> results = await provider.getInvoicesByClassroom(classroomId, month: month, year: year);
    return results.map((json) => InvoiceModel.fromJson(json)).toList();
  }

  Future<List<InvoiceModel>> getUnpaidInvoicesByStudent(String studentId) async {
    final List<dynamic> results = await provider.getUnpaidInvoicesByStudent(studentId);
    return results.map((json) => InvoiceModel.fromJson(json)).toList();
  }

  Future<void> updateInvoiceStatus(String invoiceId, String status) async {
    await provider.updateInvoiceStatus(invoiceId, status);
  }

  Future<void> insertPayment(PaymentModel payment) async {
    await provider.insertPayment(payment.toJson());
  }

  Future<int> countExcusedAbsences(String studentId, String startDate, String endDate) async {
    return await provider.countExcusedAbsences(studentId, startDate, endDate);
  }

  Future<List<String>> getAttendanceDates(String studentId, String startDate, String endDate) async {
    return await provider.getAttendanceDates(studentId, startDate, endDate);
  }

  Future<void> insertInvoices(List<InvoiceModel> invoices) async {
    // Chuyển List<InvoiceModel> thành List<Map> để đẩy lên Supabase
    final data = invoices.map((inv) => inv.toJson()).toList();
    await provider.insertInvoices(data);
  }

  Future<List<dynamic>> getStudentsByClassroom(String classroomId) async {
    return await provider.getStudentsByClassroom(classroomId);
  }
}
