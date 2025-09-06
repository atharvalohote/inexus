/*
 * ESP32 Unsecure Firmware for iNexus IoT Device Management (Simplified)
 * 
 * WARNING: This firmware accepts encrypted updates but does NOT decrypt them
 * This demonstrates the security risk of unsecure OTA updates
 * 
 * This firmware provides:
 * - WiFi client mode
 * - OTA updates (but without decryption - UNSECURE)
 * - Device status endpoint
 * - Uses only standard ESP32 libraries
 */

#include <WiFi.h>
#include <WebServer.h>
#include <Update.h>
#include <SPIFFS.h>
#include <ArduinoJson.h>

// WiFi Configuration
const char* sta_ssid = "YOUR_HOME_WIFI_SSID";        // Replace with your WiFi SSID
const char* sta_password = "YOUR_HOME_WIFI_PASSWORD"; // Replace with your WiFi password

// Firmware Information
const char* FIRMWARE_VERSION = "1.0.0-UNSECURE";
const char* DEVICE_NAME = "iNexus-ESP32";

// Server Configuration
const int SERVER_PORT = 80;
WebServer server(SERVER_PORT);

// Device Status
bool deviceOnline = false;
String staIP = "";

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== iNexus ESP32 Unsecure Firmware ===");
  Serial.println("Version: " + String(FIRMWARE_VERSION));
  Serial.println("WARNING: This firmware does NOT decrypt OTA updates!");
  
  // Initialize SPIFFS
  if (!SPIFFS.begin(true)) {
    Serial.println("SPIFFS initialization failed");
  }
  
  // Setup WiFi
  setupWiFi();
  
  // Setup web server
  setupWebServer();
  
  Serial.println("Unsecure firmware initialized successfully!");
  Serial.println("STA IP: " + staIP);
  Serial.println("Device accepts OTA updates (UNSECURE - no decryption)");
}

void loop() {
  // Handle WiFi reconnection if needed
  if (WiFi.status() != WL_CONNECTED) {
    Serial.println("WiFi connection lost. Reconnecting...");
    WiFi.reconnect();
    delay(5000);
  }
  
  // Update device status
  deviceOnline = (WiFi.status() == WL_CONNECTED);
  
  // Handle web server clients
  server.handleClient();
  
  delay(100);
}

void setupWiFi() {
  // Connect to WiFi
  WiFi.begin(sta_ssid, sta_password);
  Serial.print("Connecting to WiFi: ");
  Serial.println(sta_ssid);
  
  int attempts = 0;
  while (WiFi.status() != WL_CONNECTED && attempts < 20) {
    delay(500);
    Serial.print(".");
    attempts++;
  }
  
  if (WiFi.status() == WL_CONNECTED) {
    staIP = WiFi.localIP().toString();
    Serial.println("\nConnected to WiFi!");
    Serial.println("STA IP: " + staIP);
    deviceOnline = true;
  } else {
    Serial.println("\nFailed to connect to WiFi");
  }
}

void setupWebServer() {
  // Status endpoint - returns device information
  server.on("/status", HTTP_GET, handleStatus);
  
  // Unsecure OTA update endpoint
  server.on("/update", HTTP_POST, handleUpdate);
  
  // Root endpoint
  server.on("/", HTTP_GET, handleRoot);
  
  server.begin();
  Serial.println("Web server started on port " + String(SERVER_PORT));
}

void handleStatus() {
  Serial.println("Status request received");
  
  DynamicJsonDocument doc(512);
  doc["device_name"] = DEVICE_NAME;
  doc["firmware_version"] = FIRMWARE_VERSION;
  doc["ip_address"] = staIP + ":80";
  doc["is_online"] = deviceOnline;
  doc["ota_enabled"] = true;
  doc["ota_password_enabled"] = false;  // Unsecure firmware has no OTA password
  doc["https_support"] = false;         // HTTP only for simplicity
  doc["aes_encryption"] = false;        // This firmware does NOT support AES decryption
  doc["security_level"] = "low";
  doc["warning"] = "This firmware accepts encrypted updates without decryption";
  
  String response;
  serializeJson(doc, response);
  
  server.send(200, "application/json", response);
}

void handleUpdate() {
  Serial.println("=== UNSECURE OTA UPDATE STARTED ===");
  Serial.println("WARNING: Accepting encrypted firmware without decryption!");
  
  // Check if this is a multipart form data request
  if (server.hasArg("plain")) {
    // Handle raw data upload
    String data = server.arg("plain");
    Serial.println("Received firmware data length: " + String(data.length()));
    Serial.println("WARNING: Will flash encrypted data directly!");
    
    // Convert string to bytes
    uint8_t* firmwareData = (uint8_t*)data.c_str();
    size_t dataLen = data.length();
    
    // Begin update
    if (Update.begin(dataLen, U_FLASH)) {
      // Write encrypted data directly without decryption (UNSECURE!)
      if (Update.write(firmwareData, dataLen) == dataLen) {
        if (Update.end()) {
          Serial.println("=== UNSECURE OTA UPDATE COMPLETED ===");
          Serial.println("WARNING: Encrypted firmware installed - device may fail!");
          server.send(200, "text/plain", "Firmware update completed (UNSECURE)");
          
          // Restart the device (may fail due to encrypted firmware)
          delay(3000);
          ESP.restart();
        } else {
          Serial.println("Update end failed");
          server.send(500, "text/plain", "Update end failed");
        }
      } else {
        Serial.println("Update write failed");
        server.send(500, "text/plain", "Update write failed");
      }
    } else {
      Serial.println("Update begin failed");
      server.send(500, "text/plain", "Update begin failed");
    }
  } else {
    server.send(400, "text/plain", "No firmware data received");
  }
}

void handleRoot() {
  String html = "<html><body>";
  html += "<h1>iNexus ESP32 Unsecure Device</h1>";
  html += "<p>Firmware Version: " + String(FIRMWARE_VERSION) + "</p>";
  html += "<p>Status: " + (deviceOnline ? "Online" : "Offline") + "</p>";
  html += "<p>IP: " + staIP + "</p>";
  html += "<p style='color: red;'>WARNING: UNSECURE OTA Updates (No Decryption)</p>";
  html += "<p><a href='/status'>Device Status (JSON)</a></p>";
  html += "</body></html>";
  
  server.send(200, "text/html", html);
}

void logSecurityEvent(const char* event) {
  Serial.print("[SECURITY WARNING] ");
  Serial.println(event);
}
