import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/values/app_constants.dart';
import '../../../../core/values/app_database.dart';
import '../../../../core/values/app_strings.dart';
import '../../../../data/repositories/attendance_repository.dart';
import '../../../../global_widgets/chips/status_badge.dart';

class AttendanceItemCard extends StatelessWidget {
  final StudentWithAttendance item;
  final bool isHistoryMode;
  final Function(String status)? onStatusChanged;
  
  const AttendanceItemCard({
    super.key, 
    required this.item,
    this.isHistoryMode = false,
    this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
        border: Border.all(color: AppColors.outlineVariant.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar with ring indicator
          _buildAvatar(),
          
          const SizedBox(width: AppConstants.paddingM),
          
          // Student Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.student.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: AppColors.onBackground,
                  ),
                ),
                if (item.student.birthday != null) ...[
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      const Icon(Icons.cake_outlined, size: 12, color: AppColors.outline),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('dd/MM/yyyy').format(item.student.birthday!),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.outline,
                              fontSize: 11,
                            ),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 4),
                if (item.attendance?.checkinTime != null)
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 8, // Khoảng cách giữa giờ và tag QR
                    runSpacing: 4, // Khoảng cách nếu bị xuống dòng
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.access_time, size: 12, color: AppColors.outline),
                          const SizedBox(width: 4),
                          Text(
                            '${AppStrings.attendanceCheckinAt}: ${item.attendance!.checkinTime}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                      
                      // Hiển thị nhãn QR nếu điểm danh bằng mã
                      if (item.attendance?.method == AppDatabase.methodQr)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                              color: AppColors.primary.withOpacity(0.2),
                              width: 0.5,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.qr_code_scanner_rounded,
                                size: 10,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 3),
                              Text(
                                'QR',
                                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                      color: AppColors.primary,
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  )
                else
                  Text(
                    AppStrings.attendanceNotTaken,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontStyle: FontStyle.italic,
                          color: AppColors.outline.withValues(alpha: 0.6),
                        ),
                  ),
                
                if (isHistoryMode && item.attendance != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: StatusBadge(
                      text: _getStatusText(item.attendance!.status),
                      color: _getStatusColor(item.attendance!.status),
                      icon: _getStatusIcon(item.attendance!.status),
                    ),
                  ),
              ],
            ),
          ),

          // Attendance actions
          if (!isHistoryMode)
            _buildAttendanceOptions(),
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    final statusColor = item.attendance != null 
        ? _getStatusColor(item.attendance!.status) 
        : AppColors.outlineVariant.withValues(alpha: 0.2);

    return Container(
      width: 54,
      height: 54,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.primaryContainer.withValues(alpha: 0.3),
          shape: BoxShape.circle,
          image: item.student.avatarUrl != null 
              ? DecorationImage(
                  image: NetworkImage(item.student.avatarUrl!), 
                  fit: BoxFit.cover
                )
              : null,
        ),
        child: item.student.avatarUrl == null
            ? const Icon(Icons.person, color: AppColors.primary, size: 28)
            : null,
      ),
    );
  }

  Widget _buildAttendanceOptions() {
    final currentStatus = item.attendance?.status;
    final method = item.attendance?.method;
    
    // 1. Parent - Excused absence
    if (currentStatus == AppDatabase.statusAbsentExcused && method != AppDatabase.methodManual) {
      return const StatusBadge(
        text: AppStrings.attendanceExcused,
        color: AppColors.tertiary,
        icon: Icons.assignment_turned_in,
        isRounded: false,
      );
    }

    // 2. Interactive toggles
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _statusAction(
          icon: Icons.check_rounded,
          color: AppColors.success,
          isActive: currentStatus == AppDatabase.statusPresent,
          onTap: () => onStatusChanged?.call(AppDatabase.statusPresent),
          tooltip: AppStrings.attendancePresent,
        ),
        const SizedBox(width: 6),
        _statusAction(
          icon: Icons.priority_high_rounded,
          color: AppColors.tertiary,
          isActive: currentStatus == AppDatabase.statusAbsentExcused,
          onTap: () => onStatusChanged?.call(AppDatabase.statusAbsentExcused),
          tooltip: AppStrings.attendanceExcused,
        ),
        const SizedBox(width: 6),
        _statusAction(
          icon: Icons.close_rounded,
          color: AppColors.error,
          isActive: currentStatus == AppDatabase.statusAbsentUnexcused,
          onTap: () => onStatusChanged?.call(AppDatabase.statusAbsentUnexcused),
          tooltip: AppStrings.attendanceUnexcused,
        ),
      ],
    );
  }

  Widget _statusAction({
    required IconData icon, 
    required Color color, 
    required bool isActive, 
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(100),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive ? color : AppColors.outlineVariant.withValues(alpha: 0.4),
            width: 1.5,
          ),
        ),
        child: Icon(
          icon, 
          color: isActive ? Colors.white : AppColors.outlineVariant.withValues(alpha: 0.8), 
          size: 18,
        ),
      ),
    );
  }

  String _getStatusText(String status) {
    if (status == AppDatabase.statusPresent) return AppStrings.attendancePresent;
    if (status == AppDatabase.statusAbsentExcused) return AppStrings.attendanceExcused;
    if (status == AppDatabase.statusAbsentUnexcused) return AppStrings.attendanceUnexcused;
    return AppStrings.attendanceUnknown;
  }

  Color _getStatusColor(String status) {
    if (status == AppDatabase.statusPresent) return AppColors.success;
    if (status == AppDatabase.statusAbsentExcused) return AppColors.tertiary;
    if (status == AppDatabase.statusAbsentUnexcused) return AppColors.error;
    return AppColors.outlineVariant;
  }

  IconData _getStatusIcon(String status) {
    if (status == AppDatabase.statusPresent) return Icons.check_circle;
    if (status == AppDatabase.statusAbsentExcused) return Icons.assignment_turned_in;
    return Icons.cancel;
  }
}
