// lib/services/device_api.dart
// FIX: Corrected package name from 'imeter_app' to 'safex2'
import 'package:safex2/models/device_info.dart'; // Import the DeviceInfo model
import 'package:http/http.dart' as http; // <<-- UNCOMMENTED -->>
import 'dart:convert'; // <<-- UNCOMMENTED -->>

class DeviceApi {
  // This function will now make a REAL HTTP GET request to your NodeMCU
  Future<DeviceInfo> getDeviceInfo(String ip, int port) async {
    final uri = Uri.parse('http://$ip:$port/status'); // Use HTTP, as NodeMCU usually doesn't have HTTPS
    try {
      // Perform the actual HTTP GET request to the NodeMCU's /status endpoint
      final response = await http.get(uri).timeout(const Duration(seconds: 10)); // 10-second timeout for network

      if (response.statusCode == 200) {
        // If the NodeMCU responds successfully, decode the JSON
        final Map<String, dynamic> data = json.decode(response.body);
        data['ip_address'] = '$ip:$port'; // Ensure the connected IP:Port is stored in the info
        return DeviceInfo.fromJson(data); // Create DeviceInfo object from JSON response
      } else {
        // If NodeMCU responds with an error status code (e.g., 404, 500)
        throw Exception(
            'Failed to load device info. Status code: ${response.statusCode}. Response: ${response.body}');
      }
    } catch (e) {
      // Catch any network-related errors (e.g., device unreachable, timeout, no internet)
      print('Error getting device info: $e'); // Print to console for debugging
      throw Exception('Network/Connection error: $e. Is NodeMCU on? Is IP correct? Is your phone on the same Wi-Fi?');
    }
  }

  // This function remains SIMULATED for now, as real firmware upload is more complex
  Future<bool> uploadFirmware(String ip, int port, List<int> firmwareBytes, String fileName) async {
    // Simulate network delay for upload
    await Future.delayed(const Duration(seconds: 3));

    final bool uploadSuccess = firmwareBytes.isNotEmpty && firmwareBytes.length > 100;
    if (uploadSuccess) {
      return true; // Simulate success
    } else {
      throw Exception('Firmware upload failed on device side (simulated).'); // Simulate failure
    }
  }
}