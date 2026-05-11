import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class LedControlTile extends StatelessWidget {
  final String label;
  final Color ledColor;
  final bool isOn;
  final bool isDisabled;
  final ValueChanged<bool> onChanged;

  const LedControlTile({
    super.key,
    required this.label,
    required this.ledColor,
    required this.isOn,
    required this.isDisabled,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: isOn
            ? ledColor.withOpacity(isDark ? 0.12 : 0.08)
            : (isDark ? AppColors.darkCard : AppColors.lightCard),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOn
              ? ledColor.withOpacity(0.5)
              : (isDark ? AppColors.darkBorder : AppColors.lightBorder),
          width: isOn ? 1.5 : 1,
        ),
      ),
      child: Row(
        children: [
          // LED circle indicator
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: 14,
            height: 14,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOn
                  ? ledColor
                  : (isDark
                      ? const Color(0xFF30363D)
                      : const Color(0xFFD0D7DE)),
              boxShadow: isOn
                  ? [
                      BoxShadow(
                        color: ledColor.withOpacity(0.6),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 14),

          // Label
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: isDisabled
                        ? (isDark ? Colors.white30 : Colors.black26)
                        : null,
                  ),
                ),
                Text(
                  isOn ? 'ON' : 'OFF',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: isOn
                        ? ledColor
                        : (isDark ? Colors.white30 : Colors.black38),
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),

          // Switch
          Switch(
            value: isOn,
            onChanged: isDisabled ? null : onChanged,
            thumbColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) return ledColor;
              return null;
            }),
            trackColor: MaterialStateProperty.resolveWith((states) {
              if (states.contains(MaterialState.selected)) {
                return ledColor.withOpacity(0.4);
              }
              return null;
            }),
          ),
        ],
      ),
    );
  }
}
