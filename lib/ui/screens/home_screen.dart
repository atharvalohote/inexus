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
    // Access DeviceProvider to get all necessary state for the UI.
    final deviceProvider = Provider.of<DeviceProvider>(context);
    final bool isSmallScreen = MediaQuery.of(context).size.width < 600; // Check screen size for responsiveness

    return Scaffold(
      appBar: AppBar(
        title: const Text('iMeter Dashboard'),
        centerTitle: true, // Center the app bar title
        actions: const [
          ThemeToggle(), // Theme toggle button in app bar
          SizedBox(width: 8), // Spacing
        ],
      ),
      body: SingleChildScrollView( // Allows content to scroll if it overflows
        padding: const EdgeInsets.all(16.0), // Padding around the entire content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align children to the start (left)
          children: [
            const ConnectionForm(), // Connection form widget
            const SizedBox(height: 32.0), // Spacing

            // Device Information Section Title
            Text(
              'Device Information',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0), // Spacing

            // Conditional rendering for device info based on loading/error/data states
            if (deviceProvider.isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: SpinKitFadingCircle( // Loading animation
                    color: Colors.blue,
                    size: 50.0,
                  ),
                ),
              )
            else if (deviceProvider.errorMessage != null)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    'Error: ${deviceProvider.errorMessage}',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else if (deviceProvider.deviceInfo != null)
              // LayoutBuilder used for responsive grid layout of info cards
                LayoutBuilder(
                  builder: (context, constraints) {
                    int crossAxisCount = 1; // Default for small screens
                    if (constraints.maxWidth > 1200) {
                      crossAxisCount = 3; // 3 columns for very large screens
                    } else if (constraints.maxWidth > 600) {
                      crossAxisCount = 2; // 2 columns for medium screens
                    }
                    return GridView.builder(
                      shrinkWrap: true, // Take only necessary space
                      physics: const NeverScrollableScrollPhysics(), // Disable GridView's own scrolling
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: crossAxisCount,
                        crossAxisSpacing: 16.0, // Horizontal spacing between cards
                        mainAxisSpacing: 16.0, // Vertical spacing between cards
                        childAspectRatio: isSmallScreen ? 1.8 : 2.5, // Adjust card aspect ratio based on screen size
                      ),
                      itemCount: 6, // Total number of info cards
                      itemBuilder: (context, index) {
                        final info = deviceProvider.deviceInfo!; // Get device info
                        switch (index) {
                          case 0:
                            return CustomCard(
                              title: 'Device Status',
                              content: info.isOnline ? 'Online' : 'Offline',
                              contentColor: info.isOnline ? Colors.green[600] : Colors.red[600],
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
                              contentColor: info.otaEnabled ? Colors.green[600] : Colors.orange[600],
                              icon: Icons.cloud_upload,
                            );
                          case 4:
                            return CustomCard(
                              title: 'OTA Password',
                              content: info.otaPasswordEnabled ? 'Enabled' : 'Disabled',
                              contentColor: info.otaPasswordEnabled ? Colors.green[600] : Colors.orange[600],
                              icon: Icons.lock,
                            );
                          case 5:
                            return CustomCard(
                              title: 'HTTPS Support',
                              content: info.httpsSupport ? 'Enabled' : 'Disabled',
                              contentColor: info.httpsSupport ? Colors.green[600] : Colors.red[600],
                              icon: Icons.security,
                            );
                          default:
                            return Container(); // Fallback for unexpected index
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
                      style: Theme.of(context).textTheme.bodyLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
            const SizedBox(height: 32.0), // Spacing

            // Firmware Update Section Title
            Text(
              'Firmware Update',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16.0), // Spacing

            // Firmware Update Card
            Card(
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              margin: const EdgeInsets.all(8.0),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    ElevatedButton.icon(
                      onPressed: deviceProvider.isUploadingFirmware || deviceProvider.deviceInfo == null || !deviceProvider.deviceInfo!.isOnline
                          ? null // Disable button if uploading, no device connected, or device is offline
                          : () async {
                        await deviceProvider.pickAndUploadFirmware(); // Trigger firmware upload
                      },
                      icon: deviceProvider.isUploadingFirmware // Show loading spinner if uploading
                          ? const SpinKitThreeBounce(
                        color: Colors.white,
                        size: 20.0,
                      )
                          : const Icon(Icons.upload_file), // Upload file icon
                      label: Text(
                        deviceProvider.isUploadingFirmware ? 'Uploading...' : 'Upload Firmware (.bin)',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple[600], // Purple color for upload button
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 5,
                      ),
                    ),
                    if (deviceProvider.isUploadingFirmware)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: LinearProgressIndicator( // Progress bar during upload
                          minHeight: 8,
                          backgroundColor: Colors.purple,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.purpleAccent),
                        ),
                      ),
                    if (deviceProvider.firmwareUploadStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Text(
                          deviceProvider.firmwareUploadStatus!,
                          style: TextStyle(
                            color: deviceProvider.firmwareUploadStatus!
                                .contains('successfully') // Green for success, red for failure
                                ? Colors.green[600]
                                : Colors.red[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (deviceProvider.firmwareValidityStatus != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          deviceProvider.firmwareValidityStatus!,
                          style: TextStyle(
                            color: deviceProvider.firmwareValidityStatus!
                                .contains('valid') // Green for valid, red for invalid
                                ? Colors.green[600]
                                : Colors.red[600],
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}