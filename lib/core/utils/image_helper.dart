import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../theme/app_colors.dart';

class ImageHelper {
  ImageHelper._();

  static final ImagePicker _picker = ImagePicker();

  /// Chọn ảnh từ nguồn được chỉ định (Gallery/Camera)
  static Future<File?> pickImage(ImageSource source, {bool crop = false}) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 80, // Tăng chất lượng để crop mượt hơn, nén sau
      );
      
      if (pickedFile != null) {
        if (crop) {
          final croppedFile = await cropImage(pickedFile.path);
          return croppedFile != null ? File(croppedFile.path) : null;
        }
        return File(pickedFile.path);
      }
      return null;
    } catch (e) {
      print("Error picking image: $e");
      return null;
    }
  }

  /// Cắt ảnh
  static Future<CroppedFile?> cropImage(String sourcePath) async {
    return await ImageCropper().cropImage(
      sourcePath: sourcePath,
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Chỉnh sửa ảnh',
          toolbarColor: AppColors.primary,
          toolbarWidgetColor: Colors.white,
          statusBarColor: AppColors.primary, // Sync with toolbar
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: false,
          activeControlsWidgetColor: AppColors.primary,
        ),
        IOSUiSettings(
          title: 'Chỉnh sửa ảnh',
          cancelButtonTitle: 'Hủy',
          doneButtonTitle: 'Xong',
        ),
      ],
    );
  }

  /// Nén ảnh và trả về file đã nén.
  /// Nếu có lỗi trong quá trình nén, trả về chính file gốc.
  static Future<File> compressImage(File file, {int quality = 70}) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final targetPath = '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      final compressedFile = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
      );

      if (compressedFile != null) {
        return File(compressedFile.path);
      }
      return file;
    } catch (e) {
      print("Error compressing image in ImageHelper: $e");
      return file;
    }
  }

  /// Xóa file tạm sau khi đã sử dụng (ví dụ sau khi upload xong)
  static Future<void> deleteTempFile(File? file) async {
    try {
      if (file != null && await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print("Error deleting temp file: $e");
    }
  }
}
