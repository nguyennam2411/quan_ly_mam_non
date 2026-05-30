import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

class CloudinaryService extends GetxService {
  static CloudinaryService get to => Get.find();

  late final String _cloudName;
  late final String _uploadPreset;

  Future<CloudinaryService> init() async {
    _cloudName = dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
    _uploadPreset = dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';
    
    if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
      Get.log('WARNING: Cloudinary credentials are not properly configured in .env');
    }
    return this;
  }

  /// Uploads a file to Cloudinary using Unsigned Upload Preset.
  /// Returns the public URL of the uploaded image, or throws an exception if failed.
  Future<String?> uploadImage(File file, {String? folder}) async {
    try {
      if (_cloudName.isEmpty || _uploadPreset.isEmpty) {
        throw Exception('Cloudinary configuration is missing. Check your .env file.');
      }

      final url = Uri.parse('https://api.cloudinary.com/v1_1/$_cloudName/image/upload');
      
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = _uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      if (folder != null && folder.isNotEmpty) {
        request.fields['asset_folder'] = folder;
      }

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        return responseData['secure_url'] as String?;
      } else {
        final Map<String, dynamic> errorData = json.decode(response.body);
        final errorMessage = errorData['error']?['message'] ?? 'Unknown error';
        throw Exception('Cloudinary Upload Failed: $errorMessage (Status: ${response.statusCode})');
      }
    } catch (e) {
      Get.log('CloudinaryService uploadImage error: $e');
      rethrow;
    }
  }
}
