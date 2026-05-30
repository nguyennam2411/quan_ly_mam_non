import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/values/app_constants.dart';

class AppLineData {
  final List<FlSpot> spots;
  final Color color;
  final String label;
  final bool isDashed;
  final double strokeWidth;

  const AppLineData({
    required this.spots,
    required this.color,
    required this.label,
    this.isDashed = false,
    this.strokeWidth = 2.5,
  });
}

class AppLineChart extends StatelessWidget {
  final List<AppLineData> lines;
  final String noDataText;
  final String xTitle;
  final String yTitle;
  final double? minX;
  final double? maxX;
  final double? minY;
  final double? maxY;
  final List<Map<String, dynamic>> legendItems; // {label, color, isDashed}

  const AppLineChart({
    super.key,
    required this.lines,
    this.noDataText = 'Không có dữ liệu',
    this.xTitle = '',
    this.yTitle = '',
    this.minX,
    this.maxX,
    this.minY,
    this.maxY,
    this.legendItems = const [],
  });

  @override
  Widget build(BuildContext context) {
    final hasData = lines.any((l) => l.spots.isNotEmpty);
    if (!hasData) {
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
          aspectRatio: 1.5,
          child: LineChart(
            LineChartData(
              minX: minX,
              maxX: maxX,
              minY: minY,
              maxY: maxY,
              clipData: const FlClipData.all(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: (maxY != null && minY != null)
                    ? ((maxY! - minY!) / 5)
                    : null,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: AppColors.outlineVariant.withOpacity(0.4),
                  strokeWidth: 1,
                ),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border(
                  bottom: BorderSide(color: AppColors.outlineVariant, width: 1),
                  left: BorderSide(color: AppColors.outlineVariant, width: 1),
                ),
              ),
              titlesData: FlTitlesData(
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  axisNameWidget: xTitle.isNotEmpty
                      ? Text(xTitle,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant))
                      : null,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 28,
                    interval: 12,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        value.toInt().toString(),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ),
                ),
                leftTitles: AxisTitles(
                  axisNameWidget: yTitle.isNotEmpty
                      ? Text(yTitle,
                          style: Theme.of(context)
                              .textTheme
                              .labelSmall
                              ?.copyWith(color: AppColors.onSurfaceVariant))
                      : null,
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 36,
                    getTitlesWidget: (value, meta) => SideTitleWidget(
                      meta: meta,
                      child: Text(
                        value.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                              color: AppColors.onSurfaceVariant,
                              fontSize: 10,
                            ),
                      ),
                    ),
                  ),
                ),
              ),
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipColor: (_) => AppColors.onSurface.withOpacity(0.85),
                  getTooltipItems: (spots) {
                    return spots.map((spot) {
                      final line = lines[spot.barIndex];
                      return LineTooltipItem(
                        '${line.label}: ${spot.y.toStringAsFixed(1)}',
                        TextStyle(
                          color: line.color,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      );
                    }).toList();
                  },
                ),
              ),
              lineBarsData: lines.map((line) {
                return LineChartBarData(
                  spots: line.spots,
                  isCurved: true,
                  curveSmoothness: 0.3,
                  color: line.color,
                  barWidth: line.strokeWidth,
                  dashArray: line.isDashed ? [6, 4] : null,
                  isStrokeCapRound: true,
                  dotData: FlDotData(
                    show: !line.isDashed,
                    getDotPainter: (spot, percent, bar, index) =>
                        FlDotCirclePainter(
                      radius: 4,
                      color: line.color,
                      strokeWidth: 2,
                      strokeColor: Colors.white,
                    ),
                  ),
                  belowBarData: BarAreaData(show: false),
                );
              }).toList(),
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

  Widget _buildLegend(BuildContext context) {
    return Wrap(
      spacing: AppConstants.paddingL,
      runSpacing: AppConstants.paddingS,
      alignment: WrapAlignment.center,
      children: legendItems.map((item) {
        final isDashed = (item['isDashed'] as bool?) ?? false;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 24,
              child: isDashed
                  ? Row(children: [
                      Container(width: 7, height: 2, color: item['color'] as Color),
                      const SizedBox(width: 2),
                      Container(width: 5, height: 2, color: item['color'] as Color),
                    ])
                  : Container(
                      height: 3,
                      decoration: BoxDecoration(
                        color: item['color'] as Color,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
            ),
            const SizedBox(width: 6),
            Text(
              item['label'] as String,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: AppColors.onSurfaceVariant,
                  ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
