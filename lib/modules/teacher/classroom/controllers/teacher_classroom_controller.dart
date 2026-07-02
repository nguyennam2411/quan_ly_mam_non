import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/models/student_guardian_model.dart';
import '../../../../data/repositories/student_repository.dart';
import '../../../../data/repositories/student_guardian_repository.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/utils/app_error_message.dart';

// =============================================================================
// 1. Controller cho màn hình danh sách lớp học
// =============================================================================
class TeacherClassroomController extends GetxController {
  final StudentRepository _studentRepository;

  TeacherClassroomController({
    required StudentRepository studentRepository,
  }) : _studentRepository = studentRepository;

  final RxList<StudentModel> students = <StudentModel>[].obs;
  final RxList<StudentModel> filteredStudents = <StudentModel>[].obs;
  final RxString searchQuery = ''.obs;
  final RxBool isLoading = false.obs;
  final TextEditingController searchController = TextEditingController();

  String get classroomId => AuthService.to.classroomId.value;
  String get classroomName => AuthService.to.classroomName.value;

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  @override
  void onInit() {
    super.onInit();
    if (classroomId.isNotEmpty) {
      fetchStudents();
    }
  }

  Future<void> fetchStudents() async {
    if (classroomId.isEmpty) return;
    try {
      isLoading.value = true;
      final list = await _studentRepository.getStudentsByClassroom(classroomId);
      
      // Sắp xếp học sinh theo thứ tự alphabet của tên
      list.sort((a, b) => a.name.compareTo(b.name));
      
      students.assignAll(list);
      filterStudents(searchQuery.value);
    } catch (e) {
      debugPrint("Error fetching classroom students: $e");
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isLoading.value = false;
    }
  }

  void filterStudents(String query) {
    searchQuery.value = query;
    if (query.isEmpty) {
      filteredStudents.assignAll(students);
    } else {
      final q = query.toLowerCase();
      filteredStudents.assignAll(
        students.where((s) => s.name.toLowerCase().contains(q)).toList(),
      );
    }
  }
}

// =============================================================================
// 2. Controller cho màn hình chi tiết học sinh (dành cho giáo viên)
// =============================================================================
class TeacherStudentDetailController extends GetxController {
  final StudentGuardianRepository _guardianRepository;

  TeacherStudentDetailController({
    required StudentGuardianRepository guardianRepository,
  }) : _guardianRepository = guardianRepository;

  late final StudentModel student;

  final Rxn<Map<String, dynamic>> parentProfile = Rxn<Map<String, dynamic>>();
  final RxList<StudentGuardianModel> guardians = <StudentGuardianModel>[].obs;
  
  final RxBool isParentLoading = false.obs;
  final RxBool isGuardiansLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is StudentModel) {
      student = Get.arguments as StudentModel;
      fetchParentProfile();
      fetchGuardians();
    } else {
      Get.back();
    }
  }

  Future<void> fetchParentProfile() async {
    if (student.parentId == null) return;
    try {
      isParentLoading.value = true;
      final response = await Supabase.instance.client
          .from('users')
          .select()
          .eq('id', student.parentId!)
          .maybeSingle();
      parentProfile.value = response;
    } catch (e) {
      debugPrint("Error fetching parent profile in teacher view: $e");
    } finally {
      isParentLoading.value = false;
    }
  }

  Future<void> fetchGuardians() async {
    try {
      isGuardiansLoading.value = true;
      final response = await _guardianRepository.getGuardiansByStudent(student.id);
      guardians.assignAll(response);
    } catch (e) {
      debugPrint("Error fetching guardians in teacher view: $e");
    } finally {
      isGuardiansLoading.value = false;
    }
  }
}
