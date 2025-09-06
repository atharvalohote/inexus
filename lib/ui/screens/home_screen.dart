// lib/ui/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Ensure 'flutter_spinkit' is in pubspec.yaml
// FIX: Corrected package name from 'imeter_app' to 'safex' for all internal imports
import 'package:safex2/providers/device_provider.dart'; // Import the DeviceProvider
import 'package:safex2/ui/widgets/connection_form.dart'; // Import the ConnectionForm widget
import 'package:safex2/ui/widgets/custom_card.dart'; // Import the CustomCard widget
import 'package:safex2/ui/widgets/theme_toggle.dart'; // Import the ThemeToggle widget
 

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: AppBar(
        title: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Inexus',
            style: theme.appBarTheme.titleTextStyle,
          ),
        ),
        actions: const [
          ThemeToggle(),
          SizedBox(width: 8),
        ],
        backgroundColor: theme.appBarTheme.backgroundColor,
        foregroundColor: theme.appBarTheme.foregroundColor,
        elevation: theme.appBarTheme.elevation,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ConnectionForm(),
            const SizedBox(height: 32.0),
            
            Text(
              'Device Information',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
                fontFamily: theme.textTheme.bodyLarge?.fontFamily,
                letterSpacing: 1.1,
              ),
            ),
            const SizedBox(height: 16.0),
            if (deviceProvider.isLoading)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.primary,
                  ),
                ),
              )
            else if (deviceProvider.errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error: ${deviceProvider.errorMessage}',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.error,
                      fontWeight: FontWeight.bold,
                      fontFamily: theme.textTheme.bodyLarge?.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (deviceProvider.deviceInfo != null)
              LayoutBuilder(
                builder: (context, constraints) {
                  int crossAxisCount = 1;
                  if (constraints.maxWidth > 1200) {
                    crossAxisCount = 3;
                  } else if (constraints.maxWidth > 600) {
                    crossAxisCount = 2;
                  }
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16.0,
                      mainAxisSpacing: 16.0,
                      childAspectRatio: isSmallScreen ? 1.8 : 2.5,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) {
                      final info = deviceProvider.deviceInfo!;
                      switch (index) {
                        case 0:
                          return CustomCard(
                            title: 'Device Status',
                            content: info.isOnline ? 'Online' : 'Offline',
                            contentColor: info.isOnline ? Colors.greenAccent : theme.colorScheme.error,
                            icon: info.isOnline ? Icons.check_circle : Icons.cancel,
                          );
                        case 1:
                          return CustomCard(
                            title: 'IP Address',
                            content: info.ipAddress,
                            icon: Icons.wifi,
                          );
                        case 2:
                          return CustomCard(
                            title: 'Firmware Version',
                            content: info.firmwareVersion,
                            icon: Icons.developer_mode,
                          );
                        case 3:
                          return CustomCard(
                            title: 'OTA Update',
                            content: info.otaEnabled ? 'Enabled' : 'Disabled',
                            contentColor: info.otaEnabled ? Colors.greenAccent : Colors.orangeAccent,
                            icon: Icons.cloud_upload,
                          );
                        case 4:
                          return CustomCard(
                            title: 'OTA Password',
                            content: info.otaPasswordEnabled ? 'Enabled' : 'Disabled',
                            contentColor: info.otaPasswordEnabled ? Colors.greenAccent : Colors.orangeAccent,
                            icon: Icons.lock,
                          );
                        case 5:
                          return CustomCard(
                            title: 'HTTPS Support',
                            content: info.httpsSupport ? 'Enabled' : 'Disabled',
                            contentColor: info.httpsSupport ? Colors.greenAccent : theme.colorScheme.error,
                            icon: Icons.security,
                          );
                        default:
                          return Container();
                      }
                    },
                  );
                },
              )
            else
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Connect to a NodeMCU device to see its status.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                      fontFamily: theme.textTheme.bodyLarge?.fontFamily,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            if (deviceProvider.deviceInfo != null && deviceProvider.deviceInfo!.isOnline) ...[
              const SizedBox(height: 32.0),
              Text(
                'Firmware Update',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontFamily: theme.textTheme.bodyLarge?.fontFamily,
                  letterSpacing: 1.1,
                ),
              ),
              const SizedBox(height: 16.0),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: theme.colorScheme.primary, width: 1.2),
                ),
                color: theme.cardTheme.color,
                margin: const EdgeInsets.all(8.0),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      ElevatedButton.icon(
                        onPressed: deviceProvider.isUploadingFirmware
                            ? null
                            : () async {
                                await deviceProvider.pickAndUploadFirmware();
                              },
                        icon: deviceProvider.isUploadingFirmware
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                              )
                            : Icon(Icons.upload_rounded, color: theme.colorScheme.primary, size: 24, semanticLabel: 'Upload Firmware'),
                        label: Text(
                          deviceProvider.isUploadingFirmware ? 'Uploading...' : 'Upload Firmware (.bin)',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: theme.colorScheme.onPrimary,
                            fontFamily: 'SpaceMono',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          elevation: 2,
                        ),
                      ),
                      if (deviceProvider.isUploadingFirmware)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: LinearProgressIndicator(
                            minHeight: 8,
                            backgroundColor: Colors.black,
                            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF00FF41)),
                          ),
                        ),
                      if (deviceProvider.firmwareUploadStatus != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            deviceProvider.firmwareUploadStatus!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: deviceProvider.firmwareUploadStatus!.contains('successfully')
                                  ? Colors.greenAccent
                                  : theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SpaceMono',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      if (deviceProvider.firmwareValidityStatus != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            deviceProvider.firmwareValidityStatus!,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: deviceProvider.firmwareValidityStatus!.contains('valid')
                                  ? Colors.greenAccent
                                  : theme.colorScheme.error,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'SpaceMono',
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}