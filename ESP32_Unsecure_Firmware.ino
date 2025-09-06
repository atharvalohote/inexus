/*
 * ESP32 Unsecure Firmware for iNexus IoT Device Management
 * 
 * WARNING: This firmware accepts encrypted updates but does NOT decrypt them
 * This demonstrates the security risk of unsecure OTA updates
 * 
 * This firmware provides:
 * - AP+STA coexistence mode (WiFi client + Access Point)
 * - OTA updates (but without decryption - UNSECURE)
 * - Device status endpoint
 */

#include <WiFi.h>
#include <WebServer.h>
#include <ESPAsyncWebServer.h>
#include <Update.h>
#include <SPIFFS.h>
#include <ArduinoJson.h>

// WiFi Configuration
const char* sta_ssid = "YOUR_HOME_WIFI_SSID";        // Replace with your WiFi SSID
const char* sta_password = "YOUR_HOME_WIFI_PASSWORD"; // Replace with your WiFi password

// Access Point Configuration
const char* ap_ssid = "iNexus_Device_AP";
const char* ap_password = "inexus123";

// Firmware Information
const char* FIRMWARE_VERSION = "1.0.0-UNSECURE";
const char* DEVICE_NAME = "iNexus-ESP32";

// Server Configuration
const int SERVER_PORT = 80;
AsyncWebServer server(SERVER_PORT);

// Device Status
bool deviceOnline = false;
String staIP = "";
String apIP = "192.168.4.1";

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== iNexus ESP32 Unsecure Firmware ===");
  Serial.println("Version: " + String(FIRMWARE_VERSION));
  Serial.println("WARNING: This firmware does NOT decrypt OTA updates!");
  
  // Initialize SPIFFS
  if (!SPIFFS.begin(true)) {
    Serial.println("SPIFFS initialization failed");
  }
  
  // Setup WiFi in AP+STA mode
  setupWiFi();
  
  // Setup web server
  setupWebServer();
  
  Serial.println("Unsecure firmware initialized successfully!");
  Serial.println("STA IP: " + staIP);
  Serial.println("AP IP: " + apIP);
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
  
  delay(1000);
}

void setupWiFi() {
  // Configure WiFi in AP+STA mode
  WiFi.mode(WIFI_AP_STA);
  
  // Connect to home WiFi (STA mode)
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
  
  // Setup Access Point
  WiFi.softAP(ap_ssid, ap_password);
  Serial.println("Access Point started");
  Serial.println("AP SSID: " + String(ap_ssid));
  Serial.println("AP IP: " + apIP);
}

void setupWebServer() {
  // Status endpoint - returns device information
  server.on("/status", HTTP_GET, [](AsyncWebServerRequest *request) {
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
    
    request->send(200, "application/json", response);
  });
  
  // Unsecure OTA update endpoint (accepts encrypted data but doesn't decrypt)
  server.on("/update", HTTP_POST, [](AsyncWebServerRequest *request) {
    Serial.println("OTA update request received (UNSECURE)");
    request->send(200, "text/plain", "Ready for firmware upload (UNSECURE)");
  }, handleUpdate);
  
  // Root endpoint
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
    String html = "<html><body>";
    html += "<h1>iNexus ESP32 Unsecure Device</h1>";
    html += "<p>Firmware Version: " + String(FIRMWARE_VERSION) + "</p>";
    html += "<p>Status: " + (deviceOnline ? "Online" : "Offline") + "</p>";
    html += "<p>STA IP: " + staIP + "</p>";
    html += "<p>AP IP: " + apIP + "</p>";
    html += "<p style='color: red;'>WARNING: UNSECURE OTA Updates (No Decryption)</p>";
    html += "</body></html>";
    
    request->send(200, "text/html", html);
  });
  
  server.begin();
  Serial.println("Web server started on port " + String(SERVER_PORT));
}

void handleUpdate(AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total) {
  Serial.println("=== UNSECURE OTA UPDATE STARTED ===");
  Serial.println("WARNING: Accepting encrypted firmware without decryption!");
  Serial.println("Data length: " + String(len));
  Serial.println("Total expected: " + String(total));
  
  // Check if this is the first chunk
  if (index == 0) {
    Serial.println("Starting unsecure firmware update...");
    Serial.println("WARNING: Will flash encrypted data directly!");
    
    // Begin the update process
    if (!Update.begin(total, U_FLASH)) {
      Serial.println("Update begin failed");
      request->send(500, "text/plain", "Update begin failed");
      return;
    }
    
    Serial.println("Update process initialized (UNSECURE)");
  }
  
  // Write encrypted data directly without decryption (UNSECURE!)
  if (Update.write(data, len) != len) {
    Serial.println("Update write failed");
    request->send(500, "text/plain", "Update write failed");
    return;
  }
  
  Serial.println("Wrote " + String(len) + " bytes of encrypted data (UNSECURE)");
  
  // Check if this is the last chunk
  if (index + len >= total) {
    Serial.println("Finalizing unsecure update...");
    Serial.println("WARNING: Flashing encrypted firmware - device may not boot!");
    
    if (Update.end()) {
      Serial.println("=== UNSECURE OTA UPDATE COMPLETED ===");
      Serial.println("WARNING: Encrypted firmware installed - device may fail!");
      Serial.println("Device will restart in 3 seconds...");
      
      request->send(200, "text/plain", "Firmware update completed (UNSECURE)");
      
      // Restart the device (may fail due to encrypted firmware)
      delay(3000);
      ESP.restart();
    } else {
      Serial.println("Update end failed");
      request->send(500, "text/plain", "Update end failed");
    }
  } else {
    // Send progress response
    request->send(200, "text/plain", "Chunk received (UNSECURE)");
  }
}

void logSecurityEvent(const char* event) {
  Serial.print("[SECURITY WARNING] ");
  Serial.println(event);
}
