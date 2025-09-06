// lib/ui/widgets/theme_toggle.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// FIX: Corrected package name from 'imeter_app' to 'safex'
import 'package:safex2/providers/device_provider.dart'; // Import the DeviceProvider

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);
    return IconButton(
      icon: Icon(
        deviceProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: theme.colorScheme.primary,
      ),
      onPressed: () {
        deviceProvider.toggleTheme(!deviceProvider.isDarkMode);
      },
      tooltip: deviceProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
      style: ButtonStyle(
        overlayColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.hovered) || states.contains(MaterialState.focused)) {
            return theme.colorScheme.primary.withOpacity(0.1);
          }
          return null;
        }),
        iconColor: MaterialStateProperty.all(theme.colorScheme.primary),
      ),
    );
  }
}