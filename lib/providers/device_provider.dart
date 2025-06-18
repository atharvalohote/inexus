// lib/providers/device_provider.dart
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Ensure 'shared_preferences' in pubspec.yaml
import 'package:file_picker/file_picker.dart'; // Ensure 'file_picker' in pubspec.yaml
import 'package:fluttertoast/fluttertoast.dart'; // Ensure 'fluttertoast' in pubspec.yaml
// FIX: Corrected package name from 'imeter_app' to 'safex' for all internal imports
import 'package:safex2/models/device_info.dart'; // Import the DeviceInfo model
import 'package:safex2/services/device_api.dart'; // Import the DeviceApi service
import 'package:safex2/utils/encryption_util.dart'; // Import the EncryptionUtil utility

class DeviceProvider with ChangeNotifier {
  // Private state variables
  DeviceInfo? _deviceInfo;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDarkMode = false;
  List<String> _recentIps = [];
  bool _isUploadingFirmware = false;
  String? _firmwareUploadStatus;
  String? _firmwareValidityStatus;

  // Public getters to access state
  DeviceInfo? get deviceInfo => _deviceInfo;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isDarkMode => _isDarkMode;
  List<String> get recentIps => _recentIps;
  bool get isUploadingFirmware => _isUploadingFirmware;
  String? get firmwareUploadStatus => _firmwareUploadStatus;
  String? get firmwareValidityStatus => _firmwareValidityStatus;

  final DeviceApi _deviceApi = DeviceApi();

  // Constructor: Initializes the provider by loading saved preferences.
  DeviceProvider() {
    _loadThemePreference();
    _loadRecentIps();
  }

  // Toggles the app's theme (dark/light mode).
  void toggleTheme(bool value) {
    _isDarkMode = value;
    _saveThemePreference(value);
    notifyListeners(); // Notify listeners to rebuild widgets that depend on this state.
  }

  // Loads the saved theme preference from SharedPreferences.
  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }

  // Saves the current theme preference to SharedPreferences.
  Future<void> _saveThemePreference(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
  }

  // Loads the list of recent IP addresses from SharedPreferences.
  Future<void> _loadRecentIps() async {
    final prefs = await SharedPreferences.getInstance();
    _recentIps = prefs.getStringList('recentIps') ?? [];
    notifyListeners();
  }

  // Adds a new IP address to the list of recent connections,
  // keeping only the last 5 unique IPs.
  Future<void> _addRecentIp(String ipPort) async {
    final prefs = await SharedPreferences.getInstance();
    if (!_recentIps.contains(ipPort)) {
      _recentIps.insert(0, ipPort); // Add to the beginning
      if (_recentIps.length > 5) {
        _recentIps = _recentIps.sublist(0, 5); // Keep only the latest 5
      }
      await prefs.setStringList('recentIps', _recentIps);
      notifyListeners();
    }
  }

  // Connects to a NodeMCU device and fetches its information.
  // Updates loading, error, and device info states.
  Future<void> connectAndGetInfo(String ip, int port) async {
    _isLoading = true;
    _errorMessage = null;
    _deviceInfo = null;
    _firmwareUploadStatus = null;
    _firmwareValidityStatus = null;
    notifyListeners();

    try {
      final info = await _deviceApi.getDeviceInfo(ip, port);
      _deviceInfo = info;
      _errorMessage = null;
      _addRecentIp('$ip:$port'); // Store successful connection
      Fluttertoast.showToast(
          msg: 'Successfully connected to ${info.ipAddress}',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.green,
          textColor: Colors.white);
    } catch (e) {
      _deviceInfo = null;
      _errorMessage = 'Failed to connect: ${e.toString()}';
      Fluttertoast.showToast(
          msg: 'Failed to connect: ${e.toString()}',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.red,
          textColor: Colors.white);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Handles picking a firmware file, encrypting it, and uploading it to the device.
  Future<void> pickAndUploadFirmware() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['bin'], // Only allow .bin files for firmware
    );

    if (result != null && result.files.single.bytes != null) {
      _isUploadingFirmware = true;
      _firmwareUploadStatus = 'Encrypting and uploading firmware...';
      _firmwareValidityStatus = null;
      notifyListeners();

      try {
        final firmwareBytes = result.files.single.bytes!;
        final fileName = result.files.single.name;

        // 1. Encrypt the firmware file using the EncryptionUtil.
        final encryptedBytes = EncryptionUtil.encryptBytes(firmwareBytes);

        // 2. Upload the encrypted firmware to the connected device.
        if (_deviceInfo == null || !_deviceInfo!.isOnline) {
          throw Exception('No device connected or device is offline. Cannot upload firmware.');
        }
        final success = await _deviceApi.uploadFirmware(
          _deviceInfo!.ipAddress.split(':')[0], // Extract IP from "IP:Port" string
          int.parse(_deviceInfo!.ipAddress.split(':')[1]), // Extract port
          encryptedBytes,
          fileName,
        );

        if (success) {
          _firmwareUploadStatus = 'Firmware uploaded successfully!';
          // In a real scenario, the NodeMCU would return a detailed validation status
          // (e.g., hash match, secure boot flag). Here, we simulate it.
          _firmwareValidityStatus = 'Firmware is valid and secure (simulated)';
          Fluttertoast.showToast(
              msg: 'Firmware upload successful!',
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.green,
              textColor: Colors.white);
        } else {
          _firmwareUploadStatus = 'Firmware upload failed.';
          _firmwareValidityStatus = 'Firmware validation failed.';
          Fluttertoast.showToast(
              msg: 'Firmware upload failed.',
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.BOTTOM,
              backgroundColor: Colors.red,
              textColor: Colors.white);
        }
      } catch (e) {
        _firmwareUploadStatus = 'Firmware upload error: ${e.toString()}';
        _firmwareValidityStatus = null;
        Fluttertoast.showToast(
            msg: 'Firmware upload error: ${e.toString()}',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.BOTTOM,
            backgroundColor: Colors.grey, // Changed to grey for consistency with cancelled
            textColor: Colors.white);
      } finally {
        _isUploadingFirmware = false;
        notifyListeners();
      }
    } else {
      // User canceled the file picker operation.
      Fluttertoast.showToast(
          msg: 'Firmware upload cancelled.',
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor: Colors.grey,
          textColor: Colors.white);
    }
  }
}