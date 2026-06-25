import 'package:get/get.dart';
import '../../../../data/providers/invoice_provider.dart';
import '../../../../data/repositories/invoice_repository.dart';
import '../controllers/parent_invoice_controller.dart';

class ParentInvoiceBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<InvoiceProvider>(() => InvoiceProvider());
    Get.lazyPut<InvoiceRepository>(() => InvoiceRepository(provider: Get.find()));
    Get.lazyPut<ParentInvoiceController>(() => ParentInvoiceController(repository: Get.find()));
  }
}
