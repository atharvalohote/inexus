// lib/utils/validators.dart
class Validators {
  // Validates if a given string is a valid IPv4 address.
  static String? validateIpAddress(String? value) {
    if (value == null || value.isEmpty) {
      return 'IP address cannot be empty';
    }
    // Regular expression for basic IPv4 address validation.
    final ipRegex = RegExp(
        r'^((25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$');
    if (!ipRegex.hasMatch(value)) {
      return 'Enter a valid IPv4 address';
    }
    return null;
  }

  // Validates if a given string is a valid port number (1-65535).
  static String? validatePort(String? value) {
    if (value == null || value.isEmpty) {
      return 'Port cannot be empty';
    }
    final port = int.tryParse(value);
    if (port == null || port < 1 || port > 65535) {
      return 'Enter a valid port (1-65535)';
    }
    return null;
  }
}