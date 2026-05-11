import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/loading_view.dart';
import '../widgets/section_header.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Settings',
        subtitle: 'Theme and safety thresholds',
      ),
      body: provider.isLoading
          ? const LoadingView(message: 'Loading settings...')
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
              children: [
                // ── Dark mode ─────────────────────────────────────
                _SettingsTile(
                  icon: provider.darkMode
                      ? Icons.dark_mode_rounded
                      : Icons.light_mode_rounded,
                  title: 'Dark mode',
                  subtitle: provider.darkMode
                      ? 'Using the presentation-friendly dark theme.'
                      : 'Using the bright light theme.',
                  trailing: Switch(
                    value: provider.darkMode,
                    onChanged: provider.setDarkMode,
                  ),
                ),

                // ── Thresholds section ────────────────────────────
                const SectionHeader(title: 'Alert Thresholds'),

                // Temperature threshold
                _ThresholdCard(
                  icon: Icons.thermostat_auto_rounded,
                  color: AppColors.tempColor,
                  title: 'Temperature alert threshold',
                  value: provider.tempThreshold,
                  displayValue:
                      '${provider.tempThreshold.toStringAsFixed(0)} °C',
                  min: 20,
                  max: 60,
                  divisions: 40,
                  saving: provider.isSaving,
                  note: 'Alerts trigger when temperature exceeds this value.',
                  onChanged: provider.setTempThreshold,
                ),
                const SizedBox(height: 14),

                // ── NEW: Gas threshold ────────────────────────────
                _ThresholdCard(
                  icon: Icons.air_rounded,
                  color: AppColors.gasColor,
                  title: 'Gas / Smoke alert threshold (MQ2)',
                  value: provider.gasThreshold,
                  displayValue: '${provider.gasThreshold.toStringAsFixed(0)} %',
                  min: 10,
                  max: 90,
                  divisions: 80,
                  saving: provider.isSaving,
                  note:
                      'Buzzer and danger banner trigger above this gas level.',
                  onChanged: provider.setGasThreshold,
                ),

                // ── Firebase paths ────────────────────────────────
                const SectionHeader(title: 'Firebase database paths'),
                const _PathList(),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Generic settings tile (dark mode toggle, etc.)
// ─────────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget trailing;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primary),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
              ],
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Reusable threshold slider card
// ─────────────────────────────────────────────────────────────────
class _ThresholdCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final double value;
  final String displayValue;
  final double min;
  final double max;
  final int divisions;
  final bool saving;
  final String note;
  final ValueChanged<double> onChanged;

  const _ThresholdCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
    required this.displayValue,
    required this.min,
    required this.max,
    required this.divisions,
    required this.saving,
    required this.note,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Theme.of(context).colorScheme.outline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              Text(
                displayValue,
                style: Theme.of(context)
                    .textTheme
                    .titleMedium
                    ?.copyWith(color: color),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: color,
              thumbColor: color,
              inactiveTrackColor: color.withOpacity(0.2),
              overlayColor: color.withOpacity(0.1),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              label: displayValue,
              onChanged: onChanged,
            ),
          ),
          Text(
            saving ? 'Saving to Firebase...' : note,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────
// Firebase path chips
// ─────────────────────────────────────────────────────────────────
class _PathList extends StatelessWidget {
  const _PathList();

  @override
  Widget build(BuildContext context) {
    const paths = [
      'sensor',
      'control',
      'alerts',
      'history',
      'settings',
      'system',
    ];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: paths.map((path) {
        return Chip(
          avatar: const Icon(Icons.storage_rounded, size: 16),
          label: Text('$path/'),
        );
      }).toList(),
    );
  }
}
