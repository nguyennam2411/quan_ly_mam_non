import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_strings.dart';

class LeaveRequestFilterTabs extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusChanged;
  final Map<String, int>? statusCounts; // Optional mapping of status label -> count
  final EdgeInsetsGeometry? padding;

  const LeaveRequestFilterTabs({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    this.statusCounts,
    this.padding,
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

    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: padding,
        itemCount: statuses.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = selectedStatus == status;
          final count = statusCounts?[status];
          final activeColor = AppColors.primary;

          return InkWell(
            onTap: () => onStatusChanged(status),
            borderRadius: BorderRadius.circular(18),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : Colors.transparent,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isSelected ? activeColor : AppColors.outlineVariant.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    status,
                    style: TextStyle(
                      color: isSelected ? activeColor : AppColors.onBackground.withValues(alpha: 0.7),
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                      fontSize: 13,
                    ),
                  ),
                  if (count != null) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.all(2),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? activeColor : AppColors.outlineVariant.withValues(alpha: 0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$count',
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.outline,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
