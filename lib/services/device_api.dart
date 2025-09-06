// lib/services/device_api.dart
// FIX: Corrected package name from 'imeter_app' to 'safex2'
import 'package:safex2/models/device_info.dart'; // Import the DeviceInfo model
import 'package:http/http.dart' as http; // <<-- UNCOMMENTED -->>
import 'package:http_parser/http_parser.dart' as http_parser;
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

  // Perform a REAL HTTP POST to the NodeMCU's OTA endpoint.
  // Tries multiple upload strategies to maximize compatibility with common ESP8266 handlers.
  // Returns true on HTTP 2xx or if the device resets the connection after upload (common during OTA reboot).
  Future<bool> uploadFirmware(String ip, int port, List<int> firmwareBytes, String fileName) async {
    final uri = Uri.parse('http://$ip:$port/update');

    Future<bool> _postOctetStream() async {
      final response = await http
          .post(
            uri,
            headers: {
              'Content-Type': 'application/octet-stream',
            },
            body: firmwareBytes,
          )
          .timeout(const Duration(minutes: 2));
      return response.statusCode >= 200 && response.statusCode < 300;
    }

    Future<bool> _postMultipart(String fieldName) async {
      final req = http.MultipartRequest('POST', uri)
        ..headers['Connection'] = 'close';
      req.files.add(
        http.MultipartFile.fromBytes(
          fieldName,
          firmwareBytes,
          filename: fileName.isEmpty ? 'firmware.bin' : fileName,
          contentType: http_parser.MediaType('application', 'octet-stream'),
        ),
      );
      final streamed = await req.send().timeout(const Duration(minutes: 2));
      // Some firmwares return a small body like "OK" or JSON; treat any 2xx as success
      return streamed.statusCode >= 200 && streamed.statusCode < 300;
    }

    try {
      // Strategy 1: Arduino Update Server expects multipart field named 'update'
      if (await _postMultipart('update')) return true;

      // Strategy 2: Some handlers expect 'firmware' field
      if (await _postMultipart('firmware')) return true;

      // Strategy 3: Raw binary stream
      if (await _postOctetStream()) return true;
    } on http.ClientException catch (e) {
      // Many ESPs close the socket immediately after receiving firmware to reboot.
      final msg = e.toString().toLowerCase();
      if (msg.contains('connection closed') || msg.contains('connection reset') || msg.contains('broken pipe')) {
        // Assume success; the device is likely rebooting to apply the update.
        return true;
      }
      rethrow;
    } on Exception {
      rethrow;
    }

    // If none succeeded explicitly
    return false;
  }
}