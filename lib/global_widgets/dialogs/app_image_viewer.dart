import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import '../../core/theme/app_colors.dart';

class AppImageViewer extends StatelessWidget {
  final String? imageUrl;
  final String? filePath;
  final String title;

  const AppImageViewer({
    super.key,
    this.imageUrl,
    this.filePath,
    this.title = 'Xem ảnh',
  });

  static void show({String? imageUrl, String? filePath, String title = 'Xem ảnh'}) {
    Get.to(
      () => AppImageViewer(
        imageUrl: imageUrl,
        filePath: filePath,
        title: title,
      ),
      fullscreenDialog: true,
      transition: Transition.fadeIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider? imageProvider;
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(imageUrl!);
    } else if (filePath != null && filePath!.isNotEmpty) {
      imageProvider = FileImage(File(filePath!));
    }

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          title: Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        body: imageProvider == null
            ? const Center(child: Icon(Icons.error_outline, color: Colors.white, size: 40))
            : Container(
                constraints: BoxConstraints.expand(
                  height: MediaQuery.of(context).size.height,
                ),
                child: PhotoView(
                  imageProvider: imageProvider,
                  loadingBuilder: (context, event) => const Center(
                    child: CircularProgressIndicator(color: AppColors.primary),
                  ),
                  errorBuilder: (context, error, stackTrace) => const Center(
                    child: Icon(Icons.error_outline, color: Colors.white, size: 40),
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                  backgroundDecoration: const BoxDecoration(color: Colors.black),
                ),
              ),
      ),
    );
  }
}
