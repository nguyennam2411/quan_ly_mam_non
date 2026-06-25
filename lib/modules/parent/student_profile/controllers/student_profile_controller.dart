import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../data/models/student_model.dart';
import '../../../../data/models/health_record_model.dart';
import '../../../../data/models/student_guardian_model.dart';
import '../../../../data/repositories/health_record_repository.dart';
import '../../../../data/repositories/student_guardian_repository.dart';
import '../../../../data/repositories/student_repository.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/utils/app_error_message.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/services/parent_student_service.dart';
import '../../../../core/values/app_media_folders.dart';
import '../../../../core/values/app_strings.dart';

class StudentProfileController extends GetxController {
  final HealthRecordRepository _healthRepository;
  final StudentGuardianRepository _guardianRepository;
  final StudentRepository _studentRepository;
  
  StudentProfileController({
    required HealthRecordRepository healthRepository,
    required StudentGuardianRepository guardianRepository,
    required StudentRepository studentRepository,
  })  : _healthRepository = healthRepository,
        _guardianRepository = guardianRepository,
        _studentRepository = studentRepository;

  final Rxn<StudentModel> _studentRx = Rxn<StudentModel>();
  StudentModel get student => _studentRx.value ?? (Get.arguments as StudentModel);
  
  final Rxn<HealthRecordModel> latestHealth = Rxn<HealthRecordModel>();
  final RxList<StudentGuardianModel> guardians = <StudentGuardianModel>[].obs;
  
  final RxBool isLoading = false.obs;
  final RxBool isGuardiansLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is StudentModel) {
      _studentRx.value = Get.arguments as StudentModel;
      fetchLatestHealth();
      fetchGuardians();
    } else {
      Get.back();
      AppDialogs.error(message: AppStrings.studentProfileNotFound);
    }
  }

  Future<void> fetchLatestHealth() async {
    try {
      isLoading.value = true;
      final history = await _healthRepository.getStudentGrowthHistory(student.id);
      if (history.isNotEmpty) {
        latestHealth.value = history.last;
      }
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchGuardians() async {
    try {
      isGuardiansLoading.value = true;
      final result = await _guardianRepository.getGuardiansByStudent(student.id);
      guardians.assignAll(result);
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isGuardiansLoading.value = false;
    }
  }

  Future<void> addGuardian({
    required String name,
    required String phone,
    required String relationship,
  }) async {
    try {
      isGuardiansLoading.value = true;
      final data = {
        'student_id': student.id,
        'name': name,
        'phone': phone,
        'relationship': relationship,
      };
      final newGuardian = await _guardianRepository.createGuardian(data);
      guardians.add(newGuardian);
      AppDialogs.success(message: 'Thêm người giám hộ thành công');
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isGuardiansLoading.value = false;
    }
  }

  Future<void> editGuardian({
    required String id,
    required String name,
    required String phone,
    required String relationship,
  }) async {
    try {
      isGuardiansLoading.value = true;
      final data = {
        'name': name,
        'phone': phone,
        'relationship': relationship,
      };
      final updated = await _guardianRepository.updateGuardian(id, data);
      final index = guardians.indexWhere((e) => e.id == id);
      if (index != -1) {
        guardians[index] = updated;
      }
      AppDialogs.success(message: 'Cập nhật thông tin người giám hộ thành công');
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isGuardiansLoading.value = false;
    }
  }

  Future<void> removeGuardian(String id) async {
    try {
      isGuardiansLoading.value = true;
      await _guardianRepository.deleteGuardian(id);
      guardians.removeWhere((e) => e.id == id);
      AppDialogs.success(message: 'Xóa người giám hộ thành công');
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isGuardiansLoading.value = false;
    }
  }

  Future<void> updateStudentAvatar(ImageSource source) async {
    final pickedFile = await ImageHelper.pickImage(source, crop: true);
    if (pickedFile == null) return;

    try {
      isLoading.value = true;

      // 1. Nén ảnh
      final compressedFile = await ImageHelper.compressImage(pickedFile);

      // 2. Upload lên Cloudinary
      final uploadFolder = AppMediaFolders.studentAvatar(student.id);
      final imageUrl = await CloudinaryService.to.uploadImage(compressedFile, folder: uploadFolder);

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception('Không nhận được URL ảnh đại diện sau khi tải lên.');
      }

      // 3. Cập nhật vào DB qua Repository
      await _studentRepository.updateStudentAvatar(student.id, imageUrl);

      // 4. Đồng bộ lại dữ liệu locally
      final updatedStudent = student.copyWith(avatarUrl: imageUrl);
      _studentRx.value = updatedStudent;

      // 5. Cập nhật trong ParentStudentService để màn hình Home/Profile đồng bộ
      if (Get.isRegistered<ParentStudentService>()) {
        final service = ParentStudentService.to;
        final index = service.students.indexWhere((s) => s.id == student.id);
        if (index != -1) {
          service.students[index] = updatedStudent;
        }
        if (service.selectedStudent.value?.id == student.id) {
          service.selectedStudent.value = updatedStudent;
        }
      }

      AppDialogs.success(message: 'Cập nhật ảnh đại diện bé thành công');

      // Giải phóng file nén tạm thời
      if (compressedFile.path != pickedFile.path) {
        await ImageHelper.deleteTempFile(compressedFile);
      }
    } catch (e) {
      AppDialogs.error(message: AppErrorMessage.from(e));
    } finally {
      isLoading.value = false;
    }
  }
}
