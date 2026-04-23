import 'dart:io';
import '../../../core/utils/image_helper.dart';
import '../models/medication_request_model.dart';
import '../providers/medication_provider.dart';
import '../../../core/values/app_database.dart';

class MedicationRepository {
  final MedicationProvider _provider = MedicationProvider();

  Future<List<MedicationRequestModel>> getTeacherMedicationRequests(String classroomId) async {
    final response = await _provider.getRequestsByClassroom(classroomId);
    return (response as List).map((e) => MedicationRequestModel.fromJson(e)).toList();
  }

  Future<List<MedicationRequestModel>> getRequestsByParent(String parentId) async {
    final response = await _provider.getRequestsByParent(parentId);
    return (response as List).map((e) => MedicationRequestModel.fromJson(e)).toList();
  }

  Future<void> submitMedicationRequest(MedicationRequestModel request) async {
    await _provider.insertRequest(request.toJson());
  }

  Future<void> cancelRequest(String requestId, String reason) async {
    final data = {
      AppDatabase.colStatus: AppDatabase.cancelled,
      AppDatabase.colNote: reason, 
    };
    await _provider.updateStatus(requestId, data);
  }

  Future<void> updateRequestStatus(String requestId, String status, String teacherId) async {
    final data = {
      AppDatabase.colStatus: status,
      AppDatabase.colApprovedBy: teacherId,
      AppDatabase.colApprovedAt: DateTime.now().toIso8601String(),
    };
    await _provider.updateStatus(requestId, data);
  }

  Future<void> submitRequestWithImage(MedicationRequestModel request, File? imageFile) async {
    String? imageUrl;

    if (imageFile != null) {
      final compressedFile = await ImageHelper.compressImage(imageFile);
      imageUrl = await _provider.uploadPrescriptionImage(compressedFile);
      
      if (imageUrl == null) {
        throw Exception('Upload ảnh đơn thuốc thất bại');
      }
      
      if (compressedFile.path != imageFile.path) {
        await ImageHelper.deleteTempFile(compressedFile);
      }
    }

    final finalRequest = MedicationRequestModel(
      studentId: request.studentId,
      parentId: request.parentId,
      medicineName: request.medicineName,
      dosage: request.dosage,
      time: request.time,
      note: request.note,
      date: request.date,
      status: AppDatabase.pending,
      prescriptionImage: imageUrl,
    );

    await _provider.insertRequest(finalRequest.toJson());
  }
}
