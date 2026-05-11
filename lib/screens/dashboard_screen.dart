import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/alerts_provider.dart';
import '../providers/control_provider.dart';
import '../providers/sensor_provider.dart';
import '../theme/app_theme.dart';
import '../utils/formatters.dart';
import '../widgets/alert_tile.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_view.dart';
import '../widgets/section_header.dart';
import '../widgets/sensor_card.dart';
import '../widgets/status_badge.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sensorProvider = context.watch<SensorProvider>();
    final controlProvider = context.watch<ControlProvider>();
    final alertsProvider = context.watch<AlertsProvider>();
    final sensor = sensorProvider.sensorData;
    final status = sensorProvider.systemStatus;
    final recentAlerts = alertsProvider.alerts.take(3).toList();

    // Danger banners
    final bool gasDanger = sensor.gasLevel > 50;
    final bool flameDanger = sensor.flameDetected;

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Dashboard',
        subtitle: 'Real-time home monitoring',
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: StatusBadge(
              label: status.deviceOnline ? 'Online' : 'Offline',
              color: status.deviceOnline
                  ? AppColors.onlineColor
                  : AppColors.offlineColor,
            ),
          ),
        ],
      ),
      body: sensorProvider.isLoading
          ? const LoadingView(message: 'Loading sensor data...')
          : RefreshIndicator(
              onRefresh: () async {
                sensorProvider.startListening();
                controlProvider.startListening();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                children: [
                  // ── Danger alerts banner ──────────────────────────
                  if (gasDanger || flameDanger)
                    _DangerBanner(gas: gasDanger, flame: flameDanger),
                  if (gasDanger || flameDanger) const SizedBox(height: 12),

                  // ── Device status card ────────────────────────────
                  _StatusOverview(
                    online: status.deviceOnline,
                    lastSeen: status.lastSeen,
                    autoMode: controlProvider.state.autoMode,
                    buzzerOn: controlProvider.state.buzzerEnabled,
                  ),
                  const SizedBox(height: 10),

                  // ── Original sensors ──────────────────────────────
                  const SectionHeader(title: 'Climate Sensors'),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 560;
                      return GridView.count(
                        crossAxisCount: compact ? 1 : 3,
                        childAspectRatio: compact ? 2.15 : 1.1,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          SensorCard(
                            label: 'Temperature',
                            value: sensor.temperature.toStringAsFixed(1),
                            unit: 'C',
                            icon: Icons.thermostat_rounded,
                            color: AppColors.tempColor,
                            percentage: (sensor.temperature / 50)
                                .clamp(0, 1)
                                .toDouble(),
                          ),
                          SensorCard(
                            label: 'Humidity',
                            value: sensor.humidity.toStringAsFixed(0),
                            unit: '%',
                            icon: Icons.water_drop_rounded,
                            color: AppColors.humidColor,
                            percentage:
                                (sensor.humidity / 100).clamp(0, 1).toDouble(),
                          ),
                          SensorCard(
                            label: 'Light',
                            value: sensor.light.toStringAsFixed(0),
                            unit: '%',
                            icon: Icons.light_mode_rounded,
                            color: AppColors.lightColor,
                            percentage:
                                (sensor.light / 100).clamp(0, 1).toDouble(),
                          ),
                        ],
                      );
                    },
                  ),

                  // ── NEW sensors row ───────────────────────────────
                  const SectionHeader(title: 'Safety Sensors'),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final compact = constraints.maxWidth < 560;
                      return GridView.count(
                        crossAxisCount: compact ? 1 : 2,
                        childAspectRatio: compact ? 2.15 : 1.35,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        physics: const NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        children: [
                          // MQ2 gas
                          SensorCard(
                            label: 'Gas / Smoke (MQ2)',
                            value: sensor.gasLevel.toStringAsFixed(0),
                            unit: '%',
                            icon: Icons.air_rounded,
                            color: gasDanger
                                ? AppColors.alertDanger
                                : AppColors.gasColor,
                            percentage:
                                (sensor.gasLevel / 100).clamp(0, 1).toDouble(),
                          ),
                          // Flame sensor
                          SensorCard(
                            label: sensor.flameDetected
                                ? '⚠ FLAME DETECTED'
                                : 'Flame Sensor',
                            value: sensor.flameIntensity.toStringAsFixed(0),
                            unit: '%',
                            icon: Icons.local_fire_department_rounded,
                            color: flameDanger
                                ? AppColors.alertDanger
                                : AppColors.flameColor,
                            percentage: (sensor.flameIntensity / 100)
                                .clamp(0, 1)
                                .toDouble(),
                          ),
                        ],
                      );
                    },
                  ),

                  // ── Recent alerts ─────────────────────────────────
                  SectionHeader(
                    title: 'Recent Alerts',
                    trailing: Text(
                      '${alertsProvider.alerts.length} total',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  if (recentAlerts.isEmpty)
                    _QuietCard(
                      icon: Icons.check_circle_rounded,
                      title: 'No active alerts',
                      message: 'Everything looks calm right now.',
                    )
                  else
                    ...recentAlerts.map((alert) => AlertTile(alert: alert)),
                ],
              ),
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Danger banner shown when gas > 50 % or flame detected
// ─────────────────────────────────────────────────────────────────
class _DangerBanner extends StatelessWidget {
  final bool gas;
  final bool flame;

  const _DangerBanner({required this.gas, required this.flame});

  @override
  Widget build(BuildContext context) {
    final parts = <String>[];
    if (gas) parts.add('High gas / smoke level detected by MQ2!');
    if (flame) parts.add('Flame detected! Check for fire immediately.');

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.alertDanger.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.alertDanger.withOpacity(0.5)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.warning_rounded,
              color: AppColors.alertDanger, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: parts
                  .map((t) => Text(t,
                      style: const TextStyle(
                        color: AppColors.alertDanger,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      )))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Status overview card
// ─────────────────────────────────────────────────────────────────
class _StatusOverview extends StatelessWidget {
  final bool online;
  final int lastSeen;
  final bool autoMode;
  final bool buzzerOn;

  const _StatusOverview({
    required this.online,
    required this.lastSeen,
    required this.autoMode,
    required this.buzzerOn,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withOpacity(0.22),
            AppColors.secondary.withOpacity(0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primary.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.18),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.sensors_rounded,
                color: AppColors.primary, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Device ${online ? 'connected' : 'offline'}',
                  style: theme.textTheme.titleMedium,
                ),
                const SizedBox(height: 3),
                Text(
                  'Last seen ${Formatters.timeAgo(lastSeen)}',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              StatusBadge(
                label: autoMode ? 'Auto' : 'Manual',
                color: autoMode ? AppColors.primary : AppColors.accent,
                icon: autoMode
                    ? Icons.auto_mode_rounded
                    : Icons.touch_app_rounded,
              ),
              const SizedBox(height: 6),
              StatusBadge(
                label: buzzerOn ? 'Buzzer ON' : 'Buzzer OFF',
                color: buzzerOn ? AppColors.buzzerColor : AppColors.darkBorder,
                icon: buzzerOn
                    ? Icons.volume_up_rounded
                    : Icons.volume_off_rounded,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuietCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;

  const _QuietCard({
    required this.icon,
    required this.title,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(icon, color: AppColors.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(message, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
