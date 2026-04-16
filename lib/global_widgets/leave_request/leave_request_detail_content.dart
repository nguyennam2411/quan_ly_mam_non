import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_constants.dart';
import '../../core/values/app_database.dart';
import '../../core/values/app_strings.dart';
import '../../data/models/leave_request_model.dart';
import '../../global_widgets/chips/status_badge.dart';
import '../../global_widgets/dialogs/app_image_viewer.dart';

class LeaveRequestDetailContent extends StatelessWidget {
  final LeaveRequestModel request;

  const LeaveRequestDetailContent({
    super.key,
    required this.request,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header: Student Info
        _buildHeader(context),
        AppConstants.spacingL,

        // Leave Dates
        _buildSection(
          context,
          label: AppStrings.leaveRequestTimeInfo,
          content: Row(
            children: [
              const Icon(Icons.calendar_month_outlined, 
                  color: AppColors.primary, size: 20),
              AppConstants.spacingS,
              Text(
                _formatLeaveDates(),
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
        AppConstants.spacingM,

        // Reason
        _buildSection(
          context,
          label: AppStrings.leaveRequestReasonInfo,
          content: Text(
            request.reason,
            style: const TextStyle(height: 1.5, fontSize: 15),
          ),
        ),
        AppConstants.spacingM,

        // Cancel Reason if exists
        if (request.cancelReason != null && request.cancelReason!.isNotEmpty) ...[
          _buildSection(
            context,
            label: AppStrings.leaveRequestCancelReasonInfoLabel,
            content: Text(
              request.cancelReason!,
              style: const TextStyle(height: 1.5, color: AppColors.error, fontWeight: FontWeight.w500),
            ),
          ),
          AppConstants.spacingM,
        ],

        // Evidence
        if (request.evidenceUrl != null && request.evidenceUrl!.isNotEmpty)
          _buildSection(
            context,
            label: AppStrings.leaveRequestEvidenceInfo,
            content: GestureDetector(
              onTap: () => AppImageViewer.show(
                imageUrl: request.evidenceUrl,
                title: AppStrings.leaveRequestEvidenceTitle,
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                child: Image.network(
                  request.evidenceUrl!,
                  width: double.infinity,
                  height: 220,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 100,
                    color: AppColors.surfaceVariant,
                    child: const Icon(Icons.image_not_supported_outlined, color: AppColors.outline),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    String sentAt = '';
    if (request.createdAt != null) {
      sentAt = DateFormat('HH:mm - dd/MM/yyyy').format(request.createdAt!);
    }

    return Row(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.2),
          backgroundImage: request.student?.avatarUrl != null
              ? NetworkImage(request.student!.avatarUrl!)
              : null,
          child: request.student?.avatarUrl == null
              ? const Icon(Icons.person, color: AppColors.primary)
              : null,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                request.student?.name ?? AppStrings.unknownLabel,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              Text(
                '${AppStrings.leaveRequestSentAt} $sentAt',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (request.status) {
      case AppDatabase.pending:
        color = AppColors.warning;
        text = AppStrings.leaveStatusPending;
        break;
      case AppDatabase.approved:
        color = AppColors.success;
        text = AppStrings.leaveStatusApproved;
        break;
      case AppDatabase.rejected:
        color = AppColors.error;
        text = AppStrings.leaveStatusRejected;
        break;
      case AppDatabase.cancelled:
      default:
        color = AppColors.outline;
        text = AppStrings.leaveStatusCancelled;
        break;
    }

    return StatusBadge(
      text: text.toUpperCase(),
      color: color,
    );
  }

  Widget _buildSection(BuildContext context, {required String label, required Widget content}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.onSurfaceVariant,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
        ),
        AppConstants.spacingS,
        content,
      ],
    );
  }

  String _formatLeaveDates() {
    try {
      final start = DateTime.parse(request.startDate);
      final end = DateTime.parse(request.endDate);

      if (start == end) {
        return DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(start);
      } else {
        return '${DateFormat('dd/MM').format(start)} - ${DateFormat('dd/MM/yyyy').format(end)}';
      }
    } catch (e) {
      return '${request.startDate} - ${request.endDate}';
    }
  }
}
