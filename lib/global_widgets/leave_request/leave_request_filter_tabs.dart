import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_constants.dart';
import '../../core/values/app_strings.dart';

class LeaveRequestFilterTabs extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;

  const LeaveRequestFilterTabs({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final statuses = [
      AppStrings.leaveStatusAll,
      AppStrings.leaveStatusPending,
      AppStrings.leaveStatusApproved,
      AppStrings.leaveStatusRejected,
      AppStrings.leaveStatusCancelled,
    ];

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: statuses.map((status) {
          final isSelected = selectedStatus == status;
          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                status,
                style: TextStyle(
                  color: isSelected ? AppColors.onPrimary : AppColors.onSurfaceVariant,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              onSelected: (selected) {
                if (selected) onStatusChanged(status);
              },
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.onSurface.withValues(alpha: 0.05),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusM),
                side: BorderSide.none,
              ),
              showCheckmark: false,
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingS, vertical: 0),
              labelPadding: const EdgeInsets.symmetric(horizontal: AppConstants.paddingXS, vertical: 0),
              visualDensity: VisualDensity.compact,
            ),
          );
        }).toList(),
      ),
    );
  }
}
