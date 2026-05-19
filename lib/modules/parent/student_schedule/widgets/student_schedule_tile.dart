import 'package:flutter/material.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/data/repositories/schedule_repository.dart';
import 'package:quan_ly_mam_non/global_widgets/dialogs/app_image_viewer.dart';
import 'package:quan_ly_mam_non/global_widgets/video/youtube_player_widget.dart';

class StudentScheduleTile extends StatelessWidget {
  final ScheduleItem item;
  final bool isLast;

  const StudentScheduleTile({
    super.key,
    required this.item,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    final schedule = item.schedule;
    final lesson = item.lesson;
    final activityColor = _getActivityColor(schedule?.activityName ?? lesson?.title ?? '');
    
    // Định dạng lại thời gian (Bỏ phần giây)
    String formatTime(String? time) {
      if (time == null || !time.contains(':')) return '--:--';
      final parts = time.split(':');
      if (parts.length < 2) return '--:--';
      return '${parts[0]}:${parts[1]}';
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Phần Timeline bên trái (Nâng cấp)
          SizedBox(
            width: 75,
            child: Column(
              children: [
                const SizedBox(height: 12),
                Text(
                  formatTime(item.startTime),
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    letterSpacing: -0.5,
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 1.5,
                      color: isLast ? Colors.transparent : Colors.grey.shade200,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Nội dung bên phải
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16, right: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.activityName,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: activityColor.withOpacity(0.9),
                    ),
                  ),
                  if (lesson != null) ...[
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(height: 1, thickness: 0.5),
                    ),
                    Text(
                      'Bài học: ${lesson.title}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Colors.black87,
                      ),
                    ),
                    if (lesson.objectives != null && lesson.objectives!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Mục tiêu: ${lesson.objectives}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                    if (lesson.content != null && lesson.content!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        'Nội dung: ${lesson.content}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          height: 1.4,
                        ),
                      ),
                    ],
                    if (lesson.images.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () => AppImageViewer.show(
                          imageUrls: lesson.images,
                          initialIndex: 0,
                          title: lesson.title,
                        ),
                        child: Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                lesson.images.first,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              ),
                            ),
                            if (lesson.images.length > 1)
                              Positioned(
                                right: 12,
                                bottom: 12,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.black.withOpacity(0.6),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.collections_rounded, color: Colors.white, size: 14),
                                      const SizedBox(width: 4),
                                      Text(
                                        '+${lesson.images.length - 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                    if (lesson.youtubeUrl != null && lesson.youtubeUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      AppYoutubePlayer(youtubeId: lesson.youtubeUrl!),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String name) {
    name = name.toLowerCase();
    if (name.contains('năng khiếu') || name.contains('kỹ năng')) return Colors.purple.shade300;
    if (name.contains('học') || name.contains('văn học') || name.contains('toán')) return AppColors.primary;
    if (name.contains('ăn') || name.contains('bữa')) return Colors.orange.shade400;
    if (name.contains('ngủ') || name.contains('nghỉ trưa')) return Colors.indigo.shade300;
    if (name.contains('chơi') || name.contains('vận động')) return Colors.teal.shade400;
    if (name.contains('trả trẻ') || name.contains('đón trẻ')) return Colors.pink.shade300;
    if (name.contains('vệ sinh')) return Colors.cyan.shade400;
    return Colors.blueGrey.shade300;
  }
}
