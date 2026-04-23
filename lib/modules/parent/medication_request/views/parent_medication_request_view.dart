import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/values/app_database.dart';
import '../../../../routes/app_routes.dart';
import '../controllers/parent_medication_request_controller.dart';

class ParentMedicationRequestView extends GetView<ParentMedicationRequestController> {
  const ParentMedicationRequestView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử Dặn Thuốc'), centerTitle: true),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Get.toNamed(Routes.PARENT_CREATE_MEDICATION_REQUEST),
        child: const Icon(Icons.add),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.filteredRequests.isEmpty) {
          return const Center(child: Text('Chưa có lịch sử dặn thuốc'));
        }
        
        return ListView.builder(
          itemCount: controller.filteredRequests.length,
          itemBuilder: (context, index) {
            final request = controller.filteredRequests[index];
            return ListTile(
              title: Text(request.medicineName),
              subtitle: Text('Ngày: ${request.date} | Liều: ${request.dosage} - Giờ: ${request.time}'),
              trailing: Text(
                request.status == AppDatabase.completed
                    ? 'Đã cho uống'
                    : (request.status == AppDatabase.pending ? 'Chưa cho uống' : request.status),
                style: TextStyle(
                  color: request.status == AppDatabase.completed ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
