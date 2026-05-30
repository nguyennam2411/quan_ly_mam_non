import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../../core/theme/app_colors.dart';

class AppImageViewer extends StatefulWidget {
  final List<String> imageUrls;
  final int initialIndex;
  final String title;

  const AppImageViewer({
    super.key,
    required this.imageUrls,
    this.initialIndex = 0,
    this.title = 'Xem ảnh',
  });

  static void show({
    String? imageUrl,
    List<String>? imageUrls,
    String? filePath,
    int initialIndex = 0,
    String title = 'Xem ảnh',
  }) {
    List<String> images = [];
    if (imageUrls != null && imageUrls.isNotEmpty) {
      images = imageUrls;
    } else if (imageUrl != null) {
      images = [imageUrl];
    } else if (filePath != null) {
      images = [filePath]; // Giả định viewer tự phân biệt link/file hoặc xử lý ở build
    }

    if (images.isEmpty) return;

    Get.to(
      () => AppImageViewer(
        imageUrls: images,
        initialIndex: initialIndex,
        title: title,
      ),
      fullscreenDialog: true,
      transition: Transition.fadeIn,
    );
  }

  @override
  State<AppImageViewer> createState() => _AppImageViewerState();
}

class _AppImageViewerState extends State<AppImageViewer> {
  late PageController _pageController;
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            if (widget.imageUrls.length > 1)
              Text(
                '${_currentIndex + 1} / ${widget.imageUrls.length}',
                style: const TextStyle(color: Colors.white70, fontSize: 12),
              ),
          ],
        ),
      ),
      body: PhotoViewGallery.builder(
        scrollPhysics: const BouncingScrollPhysics(),
        builder: (BuildContext context, int index) {
          final String path = widget.imageUrls[index];
          final bool isFile = !path.startsWith('http');
          
          return PhotoViewGalleryPageOptions(
            imageProvider: isFile ? FileImage(File(path)) : NetworkImage(path) as ImageProvider,
            initialScale: PhotoViewComputedScale.contained,
            minScale: PhotoViewComputedScale.contained,
            maxScale: PhotoViewComputedScale.covered * 2,
            heroAttributes: PhotoViewHeroAttributes(tag: path),
          );
        },
        itemCount: widget.imageUrls.length,
        loadingBuilder: (context, event) => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        pageController: _pageController,
        onPageChanged: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
      ),
    );
  }
}
