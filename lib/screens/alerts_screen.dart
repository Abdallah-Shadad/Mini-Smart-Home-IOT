import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/alerts_provider.dart';
import '../widgets/alert_tile.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/empty_state.dart';
import '../widgets/loading_view.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AlertsProvider>();

    return Scaffold(
      appBar: CustomAppBar(
        title: 'Alerts',
        subtitle: 'Warnings and system events',
        actions: [
          if (provider.alerts.isNotEmpty)
            IconButton(
              tooltip: 'Clear alerts',
              onPressed: () => _confirmClear(context, provider),
              icon: const Icon(Icons.delete_sweep_rounded),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: provider.isLoading
          ? const LoadingView(message: 'Loading alerts...')
          : provider.alerts.isEmpty
              ? const EmptyState(
                  icon: Icons.notifications_off_rounded,
                  title: 'No alerts',
                  message: 'New temperature, light, and system events will appear here.',
                )
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 26),
                  itemCount: provider.alerts.length,
                  itemBuilder: (context, index) {
                    return AlertTile(alert: provider.alerts[index]);
                  },
                ),
    );
  }

  Future<void> _confirmClear(
    BuildContext context,
    AlertsProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Clear all alerts?'),
          content: const Text('This removes every alert from Firebase.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Clear'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await provider.clearAll();
    }
  }
}
