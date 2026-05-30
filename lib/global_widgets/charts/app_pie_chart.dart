import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_constants.dart';

class AppPieData {
  final double value;
  final Color color;
  final String label;

  AppPieData({
    required this.value,
    required this.color,
    required this.label,
  });
}

class AppPieChart extends StatelessWidget {
  final List<AppPieData> data;
  final String noDataText;
  final double centerSpaceRadius;
  final double sectionRadius;
  final List<Map<String, dynamic>> legendItems; // {label, color}

  const AppPieChart({
    super.key,
    required this.data,
    this.noDataText = 'Không có dữ liệu',
    this.centerSpaceRadius = 40,
    this.sectionRadius = 50,
    this.legendItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty || data.every((e) => e.value == 0)) {
      return Center(
        child: Text(
          noDataText,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.onSurfaceVariant,
              ),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 200,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: centerSpaceRadius,
              sections: _buildSections(),
              borderData: FlBorderData(show: false),
            ),
          ),
        ),
        if (legendItems.isNotEmpty) ...[
          AppConstants.spacingL,
          _buildLegend(context),
        ],
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final double total = data.fold(0, (sum, item) => sum + item.value);

    return data.map((item) {
      final double percentage = (item.value / total) * 100;
      return PieChartSectionData(
        color: item.color,
        value: item.value,
        title: '${percentage.toStringAsFixed(1)}%',
        radius: sectionRadius,
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: AppConstants.paddingL,
      runSpacing: AppConstants.paddingS,
      alignment: WrapAlignment.center,
      children: legendItems.map((item) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: item['color'] as Color,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              item['label'] as String,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
