import 'package:get/get.dart';
import '../../../../data/providers/invoice_provider.dart';
import '../../../../data/repositories/invoice_repository.dart';
import '../controllers/teacher_invoice_controller.dart';

class TeacherInvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceProvider>(() => InvoiceProvider());
    Get.lazyPut<InvoiceRepository>(() => InvoiceRepository(provider: Get.find()));
    Get.lazyPut<TeacherInvoiceController>(() => TeacherInvoiceController(repository: Get.find()));
  }
}
