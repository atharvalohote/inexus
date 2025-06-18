// lib/ui/widgets/connection_form.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart'; // Ensure 'flutter_spinkit' is in pubspec.yaml
import 'package:safex2/providers/device_provider.dart'; // Import the DeviceProvider
import 'package:safex2/utils/validators.dart'; // Import the Validators utility

class ConnectionForm extends StatefulWidget {
  const ConnectionForm({super.key});

  @override
  State<ConnectionForm> createState() => _ConnectionFormState();
}

class _ConnectionFormState extends State<ConnectionForm> {
  final _formKey = GlobalKey<FormState>(); // Global key for form validation
  final TextEditingController _ipController = TextEditingController(); // Controller for IP input
  final TextEditingController _portController = TextEditingController(); // Controller for Port input

  @override
  void initState() {
    super.initState();
    // FIX: Set a default value for the port controller when the widget initializes
    _portController.text = '80'; // Ensure the port field defaults to 80
  }

  @override
  void dispose() {
    // Dispose controllers to prevent memory leaks.
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Access DeviceProvider for state management (loading, recent IPs, connection logic).
    final deviceProvider = Provider.of<DeviceProvider>(context);
    return Card(
      elevation: 6, // Shadow depth for the card
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), // Rounded corners
      margin: const EdgeInsets.all(8.0), // Margin around the card
      child: Padding(
        padding: const EdgeInsets.all(24.0), // Padding inside the card
        child: Form(
          key: _formKey, // Assign form key for validation
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch, // Stretch children horizontally
            children: [
              Text(
                'Connect to NodeMCU',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              // IP Address input field
              TextFormField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: 'NodeMCU IP Address',
                  hintText: 'e.g., 192.168.1.100',
                  prefixIcon: const Icon(Icons.router), // Icon for IP input
                  labelStyle: Theme.of(context).inputDecorationTheme.labelStyle, // Apply theme style
                ),
                keyboardType: TextInputType.url, // Suggests URL keyboard for IP
                validator: Validators.validateIpAddress, // Use validator utility
              ),
              const SizedBox(height: 16.0),
              // Port input field
              TextFormField(
                controller: _portController,
                decoration: InputDecoration(
                  labelText: 'Port (e.g., 80)',
                  hintText: 'e.g., 80',
                  prefixIcon: const Icon(Icons.settings_input_antenna), // Icon for port input
                  labelStyle: Theme.of(context).inputDecorationTheme.labelStyle, // Apply theme style
                ),
                keyboardType: TextInputType.number, // Suggests number keyboard for port
                validator: Validators.validatePort, // Use validator utility
              ),
              const SizedBox(height: 32.0),
              // Connect button
              ElevatedButton.icon(
                onPressed: deviceProvider.isLoading // Disable button while loading
                    ? null
                    : () async {
                  if (_formKey.currentState!.validate()) { // Validate form fields
                    _formKey.currentState!.save(); // Save form state
                    await deviceProvider.connectAndGetInfo( // Call connection method
                        _ipController.text,
                        int.parse(_portController.text)); // Port is parsed here
                  }
                },
                icon: deviceProvider.isLoading // Show loading spinner if connecting
                    ? const SpinKitThreeBounce(
                  color: Colors.white,
                  size: 20.0,
                )
                    : const Icon(Icons.cast_connected), // Connection icon
                label: Text(
                  deviceProvider.isLoading ? 'Connecting...' : 'Connect',
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 5,
                ),
              ),
              const SizedBox(height: 24.0),
              // Display recent IPs (optional feature)
              Consumer<DeviceProvider>(
                builder: (context, provider, child) {
                  if (provider.recentIps.isEmpty) {
                    return const SizedBox.shrink(); // Hide if no recent IPs
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Connections:',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0, // Horizontal spacing between chips
                        runSpacing: 8.0, // Vertical spacing between rows of chips
                        children: provider.recentIps.map((ip) {
                          return ActionChip(
                            label: Text(ip),
                            onPressed: () {
                              // Populate IP and Port fields when a recent IP is tapped.
                              List<String> parts = ip.split(':');
                              _ipController.text = parts[0];
                              _portController.text = parts.length > 1 ? parts[1] : '80'; // Default port if not stored
                            },
                            backgroundColor: Theme.of(context).cardColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: Theme.of(context).dividerColor),
                            ),
                            labelStyle: Theme.of(context).textTheme.bodyMedium,
                          );
                        }).toList(),
                      ),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}