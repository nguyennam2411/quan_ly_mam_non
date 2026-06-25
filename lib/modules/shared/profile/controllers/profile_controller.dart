import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/services/auth_service.dart';
import '../../../../core/services/cloudinary_service.dart';
import '../../../../core/utils/dialog.dart';
import '../../../../core/utils/image_helper.dart';
import '../../../../core/utils/app_error_message.dart';
import '../../../../core/values/app_media_folders.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../data/repositories/profile_repository.dart';

/// Controller quản lý chỉnh sửa và cập nhật ảnh đại diện của giáo viên/phụ huynh.
class ProfileController extends GetxController {
  final ProfileRepository _repository;
  final RxBool isLoading = false.obs;
  final _supabase = Supabase.instance.client;

  ProfileController(this._repository);

  /// Chọn, nén và cập nhật avatar lên Cloudinary & Database thông qua Repository.
  /// Lỗi phát sinh được đồng bộ qua cơ chế dịch lỗi hệ thống [AppErrorMessage.from].
  Future<void> updateAvatar(ImageSource source) async {
    final pickedFile = await ImageHelper.pickImage(source, crop: true);
    if (pickedFile == null) return;

    try {
      isLoading.value = true;

      // 1. Nén ảnh
      final compressedFile = await ImageHelper.compressImage(pickedFile);

      // 2. Upload lên Cloudinary
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      final uploadFolder = AppMediaFolders.userAvatar(userId);
      final imageUrl = await CloudinaryService.to.uploadImage(compressedFile, folder: uploadFolder);

      if (imageUrl == null || imageUrl.isEmpty) {
        throw Exception(AppStrings.profileChangeAvatarErrorUpload);
      }

      // 3. Cập nhật vào DB qua Repository
      await _repository.updateAvatar(userId, imageUrl);

      // 4. Đồng bộ lại dữ liệu trong app
      await AuthService.to.refreshUserData();

      AppDialogs.success(message: AppStrings.profileChangeAvatarSuccess);

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
