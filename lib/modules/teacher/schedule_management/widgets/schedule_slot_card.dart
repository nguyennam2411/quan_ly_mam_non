import 'package:flutter/material.dart';
import 'package:quan_ly_mam_non/core/theme/app_colors.dart';
import 'package:quan_ly_mam_non/data/repositories/schedule_repository.dart';
import 'package:quan_ly_mam_non/core/values/app_database.dart';

class ScheduleSlotCard extends StatelessWidget {
  final ScheduleItem item;
  final VoidCallback? onTap;

  const ScheduleSlotCard({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lesson = item.lesson;
    final isLesson = item.isLessonSlot;
    final activityColor = _getActivityColor(item.activityName);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: activityColor.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: IntrinsicHeight(
          child: Row(
            children: [
              // Vạch màu chỉ thị bên trái
              Container(
                width: 6,
                color: activityColor,
              ),
              
              // Nội dung chính
              Expanded(
                child: InkWell(
                  onTap: isLesson ? onTap : null,
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        // Cột thời gian
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.startTime,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: Colors.grey.shade800,
                                letterSpacing: -0.5,
                              ),
                            ),
                            if (item.endTime.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                item.endTime,
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ],
                        ),
                        
                        const SizedBox(width: 20),
                        
                        // Đường kẻ dọc mờ
                        Container(
                          width: 1,
                          height: 30,
                          color: Colors.grey.shade100,
                        ),
                        
                        const SizedBox(width: 20),
                        
                        // Thông tin hoạt động
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.activityName,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  color: Colors.grey.shade900,
                                  height: 1.2,
                                ),
                              ),
                              if (item.schedule?.note != null && item.schedule!.note!.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  item.schedule!.note!,
                                  style: TextStyle(
                                    fontSize: 13, 
                                    color: Colors.grey.shade600,
                                    fontStyle: FontStyle.italic,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                              
                              // Badge trạng thái
                              if (isLesson) ...[
                                const SizedBox(height: 12),
                                lesson == null 
                                  ? _buildEmptyLessonBadge()
                                  : _buildLessonBadge(lesson),
                              ],
                            ],
                          ),
                        ),
                        
                        // Icon chỉ dẫn nếu là tiết học
                        if (isLesson)
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: activityColor.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.arrow_forward_ios_rounded, 
                              size: 14, 
                              color: activityColor
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyLessonBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.add_circle_outline_rounded, size: 14, color: Colors.grey.shade400),
          const SizedBox(width: 6),
          Text(
            'Chưa có bài soạn',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonBadge(dynamic lesson) {
    final isPublished = lesson.status == AppDatabase.statusPublished;
    final color = isPublished ? AppColors.secondary : AppColors.tertiary;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublished ? Icons.check_circle_rounded : Icons.pending_rounded, 
            size: 14, 
            color: color
          ),
          const SizedBox(width: 6),
          Text(
            isPublished ? 'Đã công khai' : 'Đang soạn thảo',
            style: TextStyle(
              color: color, 
              fontSize: 11, 
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Color _getActivityColor(String name) {
    name = name.toLowerCase();
    
    // Ưu tiên các hoạt động cụ thể trước
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
