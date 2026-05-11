import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/history_point.dart';
import '../providers/analytics_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_view.dart';
import '../widgets/section_header.dart';
import '../widgets/status_badge.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AnalyticsProvider>();
    final history = provider.history;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Analytics',
        subtitle: 'Sensor history and trends',
        actions: [
          if (provider.usingDummy)
            const Padding(
              padding: EdgeInsets.only(right: 16),
              child: StatusBadge(
                label: 'Demo data',
                color: AppColors.accent,
                icon: Icons.auto_graph_rounded,
              ),
            ),
        ],
      ),
      body: provider.isLoading
          ? const LoadingView(message: 'Preparing charts...')
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
              children: [
                _SummaryRow(history: history),
                const SectionHeader(title: 'Temperature'),
                _ChartCard(
                  color: AppColors.tempColor,
                  minY: 0,
                  maxY: 50,
                  spots: _spots(history, (point) => point.temperature),
                  unit: 'C',
                ),
                const SectionHeader(title: 'Humidity'),
                _ChartCard(
                  color: AppColors.humidColor,
                  minY: 0,
                  maxY: 100,
                  spots: _spots(history, (point) => point.humidity),
                  unit: '%',
                ),
                const SectionHeader(title: 'Light'),
                _ChartCard(
                  color: AppColors.lightColor,
                  minY: 0,
                  maxY: 100,
                  spots: _spots(history, (point) => point.light),
                  unit: '%',
                ),
              ],
            ),
    );
  }

  static List<FlSpot> _spots(
    List<HistoryPoint> history,
    double Function(HistoryPoint point) valueOf,
  ) {
    return List<FlSpot>.generate(
      history.length,
      (index) => FlSpot(index.toDouble(), valueOf(history[index])),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final List<HistoryPoint> history;

  const _SummaryRow({required this.history});

  @override
  Widget build(BuildContext context) {
    final latest = history.isEmpty ? null : history.last;

    return Row(
      children: [
        Expanded(
          child: _MetricPill(
            label: 'Avg Temp',
            value: latest == null
                ? '--'
                : '${_average(history.map((e) => e.temperature)).toStringAsFixed(1)} C',
            color: AppColors.tempColor,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricPill(
            label: 'Avg Humidity',
            value: latest == null
                ? '--'
                : '${_average(history.map((e) => e.humidity)).toStringAsFixed(0)}%',
            color: AppColors.humidColor,
          ),
        ),
      ],
    );
  }

  double _average(Iterable<double> values) {
    if (values.isEmpty) return 0;
    return values.reduce((a, b) => a + b) / values.length;
  }
}

class _MetricPill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _MetricPill({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.28)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 5),
          Text(
            value,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _ChartCard extends StatelessWidget {
  final List<FlSpot> spots;
  final Color color;
  final double minY;
  final double maxY;
  final String unit;

  const _ChartCard({
    required this.spots,
    required this.color,
    required this.minY,
    required this.maxY,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeSpots = spots.isEmpty ? const [FlSpot(0, 0)] : spots;

    return Container(
      height: 250,
      padding: const EdgeInsets.fromLTRB(12, 18, 18, 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (safeSpots.length - 1)
              .toDouble()
              .clamp(1, double.infinity)
              .toDouble(),
          minY: minY,
          maxY: maxY,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: theme.colorScheme.outline.withOpacity(0.35),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) {
                  return Text(
                    value.toInt().toString(),
                    style: theme.textTheme.bodySmall,
                  );
                },
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 28,
                interval: (safeSpots.length / 4).clamp(1, 12).toDouble(),
                getTitlesWidget: (value, meta) {
                  final index = value.round();
                  if (index < 0 || index >= spots.length) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      index == spots.length - 1
                          ? 'Now'
                          : '${spots.length - index}h',
                      style: theme.textTheme.bodySmall,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipRoundedRadius: 10,
              getTooltipItems: (items) {
                return items.map((item) {
                  return LineTooltipItem(
                    '${item.y.toStringAsFixed(1)} $unit',
                    TextStyle(color: color, fontWeight: FontWeight.w700),
                  );
                }).toList();
              },
            ),
          ),
          lineBarsData: [
            LineChartBarData(
              spots: safeSpots,
              isCurved: true,
              color: color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: color.withOpacity(0.14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
