// lib/models/device_info.dart
class DeviceInfo {
  final String ipAddress;
  final bool isOnline;
  final String firmwareVersion;
  final bool otaEnabled;
  final bool otaPasswordEnabled;
  final bool httpsSupport;
  // Add other security features as needed for your IoT devices

  DeviceInfo({
    required this.ipAddress,
    required this.isOnline,
    required this.firmwareVersion,
    required this.otaEnabled,
    required this.otaPasswordEnabled,
    required this.httpsSupport,
  });

  // Factory constructor to create a DeviceInfo instance from a JSON map.
  // This is useful when parsing responses from your NodeMCU API.
  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      ipAddress: json['ip_address'] ?? 'N/A',
      isOnline: json['is_online'] ?? false,
      firmwareVersion: json['firmware_version'] ?? 'Unknown',
      otaEnabled: json['ota_enabled'] ?? false,
      otaPasswordEnabled: json['ota_password_enabled'] ?? false,
      httpsSupport: json['https_support'] ?? false,
    );
  }
}

