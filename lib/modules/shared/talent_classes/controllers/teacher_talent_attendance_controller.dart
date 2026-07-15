import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../data/models/talent_attendance_model.dart';
import '../../../../data/models/talent_class_model.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/repositories/talent_repository.dart';
import '../../../../data/providers/student_provider.dart';

class TeacherTalentAttendanceController extends GetxController {
  final TalentRepository _repository = TalentRepository();
  final StudentProvider _studentProvider = StudentProvider();

  final TalentClassModel talentClass = Get.arguments as TalentClassModel;
  
  final RxBool isLoading = true.obs;
  
  // List of students enrolled in this class
  final RxList<StudentModel> enrolledStudents = <StudentModel>[].obs;
  
  // Map of studentId to attendance status ('PRESENT', 'ABSENT_EXCUSED', 'ABSENT_UNEXCUSED')
  final RxMap<String, String> attendanceRecords = <String, String>{}.obs;

  @override
  void onInit() {
    super.onInit();
    fetchEnrolledStudents();
  }

  Future<void> fetchEnrolledStudents() async {
    try {
      isLoading.value = true;
      
      // 1. Get all enrollments for this class
      // Note: We need a backend function or provider method to get enrollments by classId.
      // For now, let's assume we can fetch them via a new repository method.
      final enrollments = await _repository.getEnrollmentsByClass(talentClass.id!);
      
      if (enrollments.isEmpty) {
        enrolledStudents.clear();
        return;
      }

      // 2. Extract student IDs
      final studentIds = enrollments.map((e) => e.studentId).toList();

      // 3. Fetch student details (Name, Avatar, etc.)
      final studentsData = await _studentProvider.getStudentsByIds(studentIds);
      final students = studentsData.map((e) => StudentModel.fromJson(e)).toList();
      
      enrolledStudents.assignAll(students);

      // 4. Initialize attendance records with default 'PRESENT'
      for (var student in students) {
        attendanceRecords[student.id!] = 'PRESENT';
      }

    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách học sinh: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void updateAttendance(String studentId, String status) {
    attendanceRecords[studentId] = status;
  }

  Future<void> submitAttendance() async {
    try {
      isLoading.value = true;
      final today = DateTime.now().toIso8601String().substring(0, 10);
      
      List<TalentAttendanceModel> recordsToSubmit = [];
      
      for (var student in enrolledStudents) {
        final status = attendanceRecords[student.id!] ?? 'PRESENT';
        recordsToSubmit.add(
          TalentAttendanceModel(
            studentId: student.id!,
            talentClassId: talentClass.id!,
            date: DateTime.parse(today),
            status: status,
          )
        );
      }

      // 5. Submit to backend
      for (var record in recordsToSubmit) {
        await _repository.submitAttendance(record);
      }

      Get.back();
      Get.snackbar(
        'Thành công', 
        'Đã lưu điểm danh lớp ${talentClass.name}',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green.shade600,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
      );
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể lưu điểm danh: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
