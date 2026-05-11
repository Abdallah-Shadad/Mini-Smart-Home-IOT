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
                // ── Summary row ──────────────────────────────────────
                _SummaryRow(history: history),
                const SizedBox(height: 4),

                // ── Temperature ──────────────────────────────────────
                const SectionHeader(title: 'Temperature (DHT11)'),
                _ChartCard(
                  color: AppColors.tempColor,
                  minY: 0,
                  maxY: 50,
                  spots: _spots(history, (p) => p.temperature),
                  unit: '°C',
                ),

                // ── Humidity ─────────────────────────────────────────
                const SectionHeader(title: 'Humidity (DHT11)'),
                _ChartCard(
                  color: AppColors.humidColor,
                  minY: 0,
                  maxY: 100,
                  spots: _spots(history, (p) => p.humidity),
                  unit: '%',
                ),

                // ── Light ────────────────────────────────────────────
                const SectionHeader(title: 'Light Level (LDR)'),
                _ChartCard(
                  color: AppColors.lightColor,
                  minY: 0,
                  maxY: 100,
                  spots: _spots(history, (p) => p.light),
                  unit: '%',
                ),

                // ── NEW: Gas / Smoke ─────────────────────────────────
                const SectionHeader(title: 'Gas / Smoke Level (MQ2)'),
                _ChartCard(
                  color: AppColors.gasColor,
                  minY: 0,
                  maxY: 100,
                  spots: _spots(history, (p) => p.gasLevel),
                  unit: '%',
                  dangerThreshold: 50, // red zone above 50 %
                ),

                // ── NEW: Flame intensity ─────────────────────────────
                const SectionHeader(title: 'Flame Intensity (Flame Sensor)'),
                _ChartCard(
                  color: AppColors.flameColor,
                  minY: 0,
                  maxY: 100,
                  spots: _spots(history, (p) => p.flameIntensity),
                  unit: '%',
                  dangerThreshold: 20, // any reading above 20 is suspicious
                ),
              ],
            ),
    );
  }

  static List<FlSpot> _spots(
    List<HistoryPoint> history,
    double Function(HistoryPoint p) valueOf,
  ) {
    return List<FlSpot>.generate(
      history.length,
      (i) => FlSpot(i.toDouble(), valueOf(history[i])),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Summary metric pills at the top
// ─────────────────────────────────────────────────────────────────
class _SummaryRow extends StatelessWidget {
  final List<HistoryPoint> history;
  const _SummaryRow({required this.history});

  double _avg(Iterable<double> v) =>
      v.isEmpty ? 0 : v.reduce((a, b) => a + b) / v.length;

  @override
  Widget build(BuildContext context) {
    if (history.isEmpty) return const SizedBox.shrink();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        _Pill(
          label: 'Avg Temp',
          value:
              '${_avg(history.map((e) => e.temperature)).toStringAsFixed(1)} °C',
          color: AppColors.tempColor,
        ),
        _Pill(
          label: 'Avg Humidity',
          value: '${_avg(history.map((e) => e.humidity)).toStringAsFixed(0)} %',
          color: AppColors.humidColor,
        ),
        _Pill(
          label: 'Avg Gas',
          value: '${_avg(history.map((e) => e.gasLevel)).toStringAsFixed(0)} %',
          color: AppColors.gasColor,
        ),
        _Pill(
          label: 'Max Flame',
          value:
              '${history.map((e) => e.flameIntensity).reduce((a, b) => a > b ? a : b).toStringAsFixed(0)} %',
          color: AppColors.flameColor,
        ),
      ],
    );
  }
}

class _Pill extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _Pill({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Chart card — now supports optional dangerThreshold line
// ─────────────────────────────────────────────────────────────────
class _ChartCard extends StatelessWidget {
  final List<FlSpot> spots;
  final Color color;
  final double minY;
  final double maxY;
  final String unit;
  final double? dangerThreshold; // draws a dashed red line if provided

  const _ChartCard({
    required this.spots,
    required this.color,
    required this.minY,
    required this.maxY,
    required this.unit,
    this.dangerThreshold,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safeSpots = spots.isEmpty ? const [FlSpot(0, 0)] : spots;

    return Container(
      height: 220,
      padding: const EdgeInsets.fromLTRB(12, 18, 18, 10),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.colorScheme.outline),
      ),
      child: LineChart(
        LineChartData(
          minX: 0,
          maxX: (safeSpots.length - 1).toDouble().clamp(1, double.infinity),
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
          // Extra horizontal lines: danger threshold
          extraLinesData: dangerThreshold != null
              ? ExtraLinesData(
                  horizontalLines: [
                    HorizontalLine(
                      y: dangerThreshold!,
                      color: AppColors.alertDanger.withOpacity(0.7),
                      strokeWidth: 1.5,
                      dashArray: [6, 4],
                      label: HorizontalLineLabel(
                        show: true,
                        alignment: Alignment.topRight,
                        style: const TextStyle(
                          color: AppColors.alertDanger,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                        labelResolver: (_) => ' ALERT',
                      ),
                    ),
                  ],
                )
              : null,
          titlesData: FlTitlesData(
            topTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles:
                const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 38,
                interval: maxY / 4,
                getTitlesWidget: (value, meta) => Text(
                  value.toInt().toString(),
                  style: theme.textTheme.bodySmall,
                ),
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
              getTooltipItems: (items) => items
                  .map((item) => LineTooltipItem(
                        '${item.y.toStringAsFixed(1)} $unit',
                        TextStyle(color: color, fontWeight: FontWeight.w700),
                      ))
                  .toList(),
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
                color: color.withOpacity(0.12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
