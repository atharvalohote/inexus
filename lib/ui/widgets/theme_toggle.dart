// lib/ui/widgets/theme_toggle.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
// FIX: Corrected package name from 'imeter_app' to 'safex'
import 'package:safex2/providers/device_provider.dart'; // Import the DeviceProvider

class ThemeToggle extends StatelessWidget {
  const ThemeToggle({super.key});

  @override
  Widget build(BuildContext context) {
    // Access the DeviceProvider to get and toggle the theme mode.
    final deviceProvider = Provider.of<DeviceProvider>(context);
    return IconButton(
      icon: Icon(
        // Display a sun icon for light mode, moon for dark mode.
        deviceProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
        color: Theme.of(context).appBarTheme.foregroundColor, // Icon color matches app bar foreground
      ),
      onPressed: () {
        // Call the toggleTheme method in DeviceProvider.
        deviceProvider.toggleTheme(!deviceProvider.isDarkMode);
      },
      tooltip: deviceProvider.isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode',
    );
  }
}