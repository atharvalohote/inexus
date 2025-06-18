// main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import 'package:safex2/providers/device_provider.dart'; // Custom provider
import 'package:safex2/ui/screens/home_screen.dart'; // Home screen
import 'package:safex2/ui/themes/app_themes.dart'; // Custom themes

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => DeviceProvider()),
      ],
      child: Consumer<DeviceProvider>(
        builder: (context, deviceProvider, child) {
          return MaterialApp.router(
            title: 'iMeter',
            theme: AppThemes.lightTheme,
            darkTheme: AppThemes.darkTheme,
            themeMode: deviceProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            routerConfig: GoRouter(
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => const HomeScreen(),
                ),
              ],
            ),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}