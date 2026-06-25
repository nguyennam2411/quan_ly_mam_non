import 'package:get/get.dart';
import '../../../../data/models/talent_class_model.dart';
import '../../../../data/repositories/talent_repository.dart';

class TeacherTalentController extends GetxController {
  final TalentRepository _repository = TalentRepository();

  final RxList<TalentClassModel> talentClasses = <TalentClassModel>[].obs;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTalentClasses();
  }

  Future<void> fetchTalentClasses() async {
    try {
      isLoading.value = true;
      // In reality, this should fetch classes assigned to the current teacher,
      // but for now we fetch all to keep it simple, or repository handles it.
      final classes = await _repository.getAllTalentClasses();
      talentClasses.assignAll(classes);
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tải danh sách lớp năng khiếu');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createClass(TalentClassModel newClass) async {
    try {
      isLoading.value = true;
      await _repository.createTalentClass(newClass);
      Get.snackbar('Thành công', 'Đã tạo lớp năng khiếu mới!');
      await fetchTalentClasses(); // Refresh list
    } catch (e) {
      Get.snackbar('Lỗi', 'Không thể tạo lớp: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
