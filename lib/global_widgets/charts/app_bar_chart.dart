import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_constants.dart';

class AppBarGroup {
  final int x;
  final List<double> values;
  final List<Color> colors;

  AppBarGroup({
    required this.x,
    required this.values,
    required this.colors,
  });
}

class AppBarChart extends StatelessWidget {
  final List<AppBarGroup> groups;
  final List<String> bottomLabels;
  final double? maxY;
  final String noDataText;
  final List<Map<String, dynamic>> legendItems; // {label, color}

  const AppBarChart({
    super.key,
    required this.groups,
    required this.bottomLabels,
    this.maxY,
    this.noDataText = 'Không có dữ liệu',
    this.legendItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (groups.isEmpty) {
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
        AspectRatio(
          aspectRatio: 1.7,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY ?? _calculateMaxY(),
              barTouchData: BarTouchData(
                enabled: true,
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => AppColors.onSurface.withValues(alpha: 0.8),
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      rod.toY.toInt().toString(),
                      Theme.of(context).textTheme.labelMedium!.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: _getBottomTitles,
                    reservedSize: 32,
                  ),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    getTitlesWidget: (value, meta) => Text(
                      value.toInt().toString(),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.outline,
                            fontSize: 10,
                          ),
                    ),
                  ),
                ),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              barGroups: _getBarGroups(),
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

  double _calculateMaxY() {
    double max = 0;
    for (var group in groups) {
      for (var val in group.values) {
        if (val > max) max = val;
      }
    }
    return max + 2;
  }

  List<BarChartGroupData> _getBarGroups() {
    return groups.map((g) {
      return BarChartGroupData(
        x: g.x,
        barRods: List.generate(g.values.length, (index) {
          return BarChartRodData(
            toY: g.values[index],
            color: g.colors[index],
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          );
        }),
      );
    }).toList();
  }

  Widget _getBottomTitles(double value, TitleMeta meta) {
    final index = value.toInt();
    if (index < 0 || index >= bottomLabels.length) {
      return const SizedBox();
    }

    return SideTitleWidget(
      meta: meta,
      space: 8,
      child: Text(
        bottomLabels[index],
        style: const TextStyle(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.bold,
          fontSize: 12,
        ),
      ),
    );
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
