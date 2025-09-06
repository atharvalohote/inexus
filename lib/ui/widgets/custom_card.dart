// lib/ui/widgets/custom_card.dart
import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final String title; // Title of the card (e.g., "Device Status")
  final String content; // Main content displayed on the card (e.g., "Online")
  final Color? contentColor; // Optional color for the content text
  final IconData? icon; // Optional icon to display next to the title

  const CustomCard({
    super.key,
    required this.title,
    required this.content,
    this.contentColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary, width: 1.2),
      ),
      color: theme.cardTheme.color,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (icon != null) ...[
                  Icon(
                    _getMinimalIcon(icon),
                    size: 24,
                    color: theme.colorScheme.primary,
                    semanticLabel: title,
                  ),
                  const SizedBox(width: 10),
                ],
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.primary,
                    fontFamily: theme.textTheme.bodyLarge?.fontFamily,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12.0),
            Text(
              content,
              style: theme.textTheme.displaySmall?.copyWith(
                color: contentColor ?? theme.colorScheme.primary,
                fontFamily: 'SpaceMono',
                fontWeight: FontWeight.bold,
                fontSize: 28,
                letterSpacing: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Map filled icons to minimal/outlined/rounded icons
  IconData _getMinimalIcon(IconData? icon) {
    switch (icon) {
      case Icons.check_circle:
        return Icons.check_circle_outline;
      case Icons.cancel:
        return Icons.cancel_outlined;
      case Icons.wifi:
        return Icons.wifi_outlined;
      case Icons.developer_mode:
        return Icons.code;
      case Icons.cloud_upload:
        return Icons.cloud_upload_outlined;
      case Icons.lock:
        return Icons.lock_outline;
      case Icons.security:
        return Icons.shield_outlined;
      default:
        return icon ?? Icons.circle_outlined;
    }
  }
}