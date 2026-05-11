import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/alerts_provider.dart';
import '../providers/analytics_provider.dart';
import '../providers/control_provider.dart';
import '../providers/sensor_provider.dart';
import '../providers/settings_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    await context.read<SettingsProvider>().init();
    if (!mounted) return;

    context.read<SensorProvider>().startListening();
    context.read<ControlProvider>().startListening();
    context.read<AlertsProvider>().startListening();
    context.read<AnalyticsProvider>().startListening();

    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, animation, __) => const HomeScreen(),
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 86,
              height: 86,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.primary.withOpacity(0.28)),
              ),
              child: const Icon(
                Icons.home_rounded,
                color: AppColors.primary,
                size: 46,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Mini Smart Home',
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Syncing your IoT dashboard',
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 28),
            const SizedBox(
              width: 34,
              height: 34,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
          ],
        ),
      ),
    );
  }
}
