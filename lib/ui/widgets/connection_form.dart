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
    final theme = Theme.of(context);
    final deviceProvider = Provider.of<DeviceProvider>(context);
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: theme.colorScheme.primary, width: 1.2),
      ),
      color: theme.cardTheme.color,
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Connect to NodeMCU',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  fontFamily: theme.textTheme.bodyLarge?.fontFamily,
                  letterSpacing: 1.1,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24.0),
              TextFormField(
                controller: _ipController,
                decoration: InputDecoration(
                  labelText: 'NodeMCU IP Address',
                  hintText: 'e.g., 192.168.1.100',
                  prefixIcon: Icon(Icons.lan_outlined, color: theme.colorScheme.primary, size: 24, semanticLabel: 'IP Address'),
                  labelStyle: theme.inputDecorationTheme.labelStyle,
                  hintStyle: theme.inputDecorationTheme.hintStyle,
                ),
                style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'SpaceMono'),
                keyboardType: TextInputType.url,
                validator: Validators.validateIpAddress,
                autofillHints: const [AutofillHints.url],
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _portController,
                decoration: InputDecoration(
                  labelText: 'Port (e.g., 80)',
                  hintText: 'e.g., 80',
                  prefixIcon: Icon(Icons.input_outlined, color: theme.colorScheme.primary, size: 24, semanticLabel: 'Port'),
                  labelStyle: theme.inputDecorationTheme.labelStyle,
                  hintStyle: theme.inputDecorationTheme.hintStyle,
                ),
                style: theme.textTheme.bodyLarge?.copyWith(fontFamily: 'SpaceMono'),
                keyboardType: TextInputType.number,
                validator: Validators.validatePort,
                // autofillHints: const [AutofillHints.port], // Removed invalid hint
              ),
              const SizedBox(height: 32.0),
              ElevatedButton.icon(
                onPressed: deviceProvider.isLoading
                    ? null
                    : () async {
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState!.save();
                          await deviceProvider.connectAndGetInfo(
                              _ipController.text,
                              int.parse(_portController.text));
                        }
                      },
                icon: deviceProvider.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Icon(Icons.play_arrow_rounded, color: theme.colorScheme.primary, size: 24, semanticLabel: 'Connect'),
                label: Text(
                  deviceProvider.isLoading ? 'Connecting...' : 'Connect',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: theme.colorScheme.onPrimary,
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
              const SizedBox(height: 24.0),
              Consumer<DeviceProvider>(
                builder: (context, provider, child) {
                  if (provider.recentIps.isEmpty) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recent Connections:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                          fontFamily: theme.textTheme.bodyLarge?.fontFamily,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: provider.recentIps.map((ip) {
                          return ActionChip(
                            label: Text(ip, style: theme.textTheme.bodyMedium),
                            onPressed: () {
                              List<String> parts = ip.split(':');
                              _ipController.text = parts[0];
                              _portController.text = parts.length > 1 ? parts[1] : '80';
                            },
                            backgroundColor: theme.cardTheme.color,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                              side: BorderSide(color: theme.colorScheme.primary),
                            ),
                            labelStyle: theme.textTheme.bodyMedium,
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