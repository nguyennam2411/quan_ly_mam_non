import 'dart:io';
import 'package:flutter/material.dart';
import 'package:quan_ly_mam_non/core/utils/image_helper.dart';
import 'package:quan_ly_mam_non/core/utils/dialog.dart';
import 'package:quan_ly_mam_non/global_widgets/dialogs/app_image_viewer.dart';

class ImagePickerGrid extends StatelessWidget {
  final List<dynamic> images;
  final Function(File) onImageAdded;
  final Function(int) onImageRemoved;
  final int maxImages;

  const ImagePickerGrid({
    super.key,
    required this.images,
    required this.onImageAdded,
    required this.onImageRemoved,
    this.maxImages = 5,
  });

  Future<void> _pickImage() async {
    final source = await AppDialogs.showImageSourcePicker(
      title: 'Chọn nguồn ảnh minh họa',
    );
    if (source != null) {
      final file = await ImageHelper.pickImage(source, crop: true);
      if (file != null) {
        onImageAdded(file);
      }
    }
  }

  void _viewImage(int index) {
    // Chuyển đổi danh sách mixed (File/String) sang String để viewer hiểu
    final List<String> paths = images.map((img) {
      if (img is File) return img.path;
      return img.toString();
    }).toList();

    AppImageViewer.show(
      imageUrls: paths,
      initialIndex: index,
      title: 'Xem ảnh minh họa',
    );
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: images.length < maxImages ? images.length + 1 : images.length,
      itemBuilder: (context, index) {
        if (index == images.length && images.length < maxImages) {
          return _buildAddButton();
        }
        return _buildImageItem(index);
      },
    );
  }

  Widget _buildAddButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: const Icon(Icons.add_a_photo_outlined, color: Colors.grey),
      ),
    );
  }

  Widget _buildImageItem(int index) {
    final image = images[index];
    return Stack(
      children: [
        Positioned.fill(
          child: GestureDetector(
            onTap: () => _viewImage(index),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: image is File
                  ? Image.file(image, fit: BoxFit.cover)
                  : Image.network(image.toString(), fit: BoxFit.cover),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => onImageRemoved(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, size: 16, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
