import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_constants.dart';
import '../../core/values/app_database.dart';
import '../../core/values/app_strings.dart';
import '../../data/models/medication_request_model.dart';
import '../chips/status_badge.dart';

class AppMedicationRequestCard extends StatelessWidget {
  final MedicationRequestModel request;
  final Widget? actions;
  final VoidCallback? onDetail;

  const AppMedicationRequestCard({
    super.key,
    required this.request,
    this.actions,
    this.onDetail,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppConstants.paddingM),
      padding: const EdgeInsets.all(AppConstants.paddingM),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(AppConstants.radiusXL),
        boxShadow: [
          BoxShadow(
            color: AppColors.onSurface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          AppConstants.spacingM,
          _buildMedicationDetails(context),
          AppConstants.spacingM,
          _buildActionsRow(context),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final student = request.student;
    final createdAt = request.createdAt ?? DateTime.now();

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Avatar
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.primaryContainer.withValues(alpha: 0.2),
          backgroundImage: student?.avatarUrl != null 
              ? NetworkImage(student!.avatarUrl!) 
              : null,
          child: student?.avatarUrl == null 
              ? Icon(Icons.person, color: AppColors.primary) 
              : null,
        ),
        const SizedBox(width: AppConstants.paddingM),

        // Info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      student?.name ?? AppStrings.unknownLabel,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  _buildStatusBadge(),
                ],
              ),
              AppConstants.spacingXXS,
              Text(
                'Đã gửi lúc: ${DateFormat('HH:mm - dd/MM/yyyy').format(createdAt.toLocal())}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.outline,
                ),
              ),
              AppConstants.spacingS,
              Row(
                children: [
                  Icon(Icons.calendar_today_rounded, size: 16, color: AppColors.primary),
                  const SizedBox(width: AppConstants.paddingS),
                  Text(
                    _formatMedicationDate(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    Color color;
    String text;

    switch (request.status) {
      case AppDatabase.pending:
        color = AppColors.warning;
        text = AppStrings.medicationStatusPending;
        break;
      case AppDatabase.completed:
        color = AppColors.success;
        text = AppStrings.medicationStatusCompleted;
        break;
      case AppDatabase.rejected:
        color = AppColors.error;
        text = AppStrings.medicationStatusMedical;
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

  Widget _buildMedicationDetails(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Tên thuốc: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                request.medicineName,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'Liều lượng: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                request.dosage,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Row(
          children: [
            Text(
              'Giờ uống: ',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            Expanded(
              child: Text(
                request.time,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.onSurfaceVariant,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsRow(BuildContext context) {
    return Row(
      children: [
        if (actions != null) actions!,
        const Spacer(),
        TextButton(
          onPressed: onDetail,
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Chi tiết',
                style: TextStyle(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.arrow_forward_ios_rounded, size: 12, color: AppColors.primary),
            ],
          ),
        ),
      ],
    );
  }

  String _formatMedicationDate() {
    try {
      final parsed = DateTime.parse(request.date);
      return DateFormat('EEEE, dd/MM/yyyy', 'vi_VN').format(parsed);
    } catch (e) {
      return request.date;
    }
  }
}
