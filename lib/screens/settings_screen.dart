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
                const SectionHeader(title: 'Automation'),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.thermostat_auto_rounded,
                            color: AppColors.tempColor,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Temperature alert threshold',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          Text(
                            '${provider.tempThreshold.toStringAsFixed(0)} C',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(color: AppColors.tempColor),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Slider(
                        value: provider.tempThreshold.clamp(20, 60).toDouble(),
                        min: 20,
                        max: 60,
                        divisions: 40,
                        label:
                            '${provider.tempThreshold.toStringAsFixed(0)} C',
                        onChanged: provider.setTempThreshold,
                      ),
                      Text(
                        provider.isSaving
                            ? 'Saving threshold to Firebase...'
                            : 'Alerts can use this value to flag overheating.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                const SectionHeader(title: 'Firebase paths'),
                const _PathList(),
              ],
            ),
    );
  }
}

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

class _PathList extends StatelessWidget {
  const _PathList();

  @override
  Widget build(BuildContext context) {
    const paths = ['sensor', 'control', 'alerts', 'history', 'settings', 'system'];

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
