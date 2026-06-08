import 'package:get/get.dart';
import '../../data/models/student_model.dart';
import '../../data/repositories/student_repository.dart';
import 'auth_service.dart';
import 'notification_service.dart';

class ParentStudentService extends GetxService {
  static ParentStudentService get to => Get.find();

  final StudentRepository _repository;
  
  final RxList<StudentModel> students = <StudentModel>[].obs;
  final Rxn<StudentModel> selectedStudent = Rxn<StudentModel>();
  final RxBool isLoading = false.obs;

  ParentStudentService(this._repository);

  @override
  void onInit() {
    super.onInit();
    fetchStudents();
  }

  Future<void> fetchStudents() async {
    try {
      isLoading.value = true;
      final parentId = AuthService.to.currentUser.value?.id;
      if (parentId != null) {
        final result = await _repository.getStudentsByParent(parentId);
        students.assignAll(result);
        
        // Mặc định chọn bé đầu tiên nếu chưa có lựa chọn
        if (students.isNotEmpty && selectedStudent.value == null) {
          selectedStudent.value = students.first;
        }

        // Đồng bộ hóa các topic thông báo lớp học của các con
        if (Get.isRegistered<NotificationService>()) {
          await NotificationService.to.syncClassroomSubscriptions();
        }
      }
    } catch (e) {
      // Có thể log lỗi ra service tập trung
    } finally {
      isLoading.value = false;
    }
  }

  void selectStudent(StudentModel student) {
    selectedStudent.value = student;
  }

  void clear() {
    students.clear();
    selectedStudent.value = null;
    isLoading.value = false;
  }
}
