import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/control_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/led_control_tile.dart';
import '../widgets/loading_view.dart';
import '../widgets/section_header.dart';

class ControlScreen extends StatelessWidget {
  const ControlScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ControlProvider>();
    final state = provider.state;

    return Scaffold(
      appBar: const CustomAppBar(
        title: 'Controls',
        subtitle: 'Manage lights and automation',
      ),
      body: provider.isLoading
          ? const LoadingView(message: 'Loading controls...')
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
              children: [
                _AutoModeCard(
                  enabled: state.autoMode,
                  saving: provider.isSaving,
                  onChanged: provider.setAutoMode,
                ),
                const SizedBox(height: 8),
                SectionHeader(
                  title: 'LED Lights',
                  trailing: provider.isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : null,
                ),
                LedControlTile(
                  label: 'Red LED',
                  ledColor: AppColors.redLed,
                  isOn: state.redLed,
                  isDisabled: state.autoMode || provider.isSaving,
                  onChanged: provider.setRedLed,
                ),
                const SizedBox(height: 12),
                LedControlTile(
                  label: 'Green LED',
                  ledColor: AppColors.greenLed,
                  isOn: state.greenLed,
                  isDisabled: state.autoMode || provider.isSaving,
                  onChanged: provider.setGreenLed,
                ),
                const SizedBox(height: 12),
                LedControlTile(
                  label: 'Yellow LED',
                  ledColor: AppColors.yellowLed,
                  isOn: state.yellowLed,
                  isDisabled: state.autoMode || provider.isSaving,
                  onChanged: provider.setYellowLed,
                ),
                if (provider.error != null) ...[
                  const SizedBox(height: 16),
                  _InlineError(message: provider.error!),
                ],
              ],
            ),
    );
  }
}

class _AutoModeCard extends StatelessWidget {
  final bool enabled;
  final bool saving;
  final ValueChanged<bool> onChanged;

  const _AutoModeCard({
    required this.enabled,
    required this.saving,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: enabled
            ? AppColors.primary.withOpacity(0.14)
            : theme.colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: enabled
              ? AppColors.primary.withOpacity(0.45)
              : theme.colorScheme.outline,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.auto_mode_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Automatic mode', style: theme.textTheme.titleMedium),
                const SizedBox(height: 3),
                Text(
                  enabled
                      ? 'Device logic is controlling the LEDs.'
                      : 'Manual LED controls are enabled.',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Switch(value: enabled, onChanged: saving ? null : onChanged),
        ],
      ),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;

  const _InlineError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.offlineColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.offlineColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_rounded, color: AppColors.offlineColor),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message, style: Theme.of(context).textTheme.bodySmall),
          ),
        ],
      ),
    );
  }
}
