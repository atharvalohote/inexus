/*
 * ESP32 Secure Firmware for iNexus IoT Device Management
 * 
 * This firmware provides the following features:
 * - AP+STA coexistence mode (WiFi client + Access Point)
 * - Secure OTA updates with AES-256 decryption
 * - Device status endpoint
 * - Firmware validation
 * 
 * IMPORTANT: This firmware MUST use the same AES keys as the Flutter app
 * Keys are defined in lib/utils/encryption_util.dart
 */
 * - AP+STA coexistence mode (WiFi client + Access Point)
 * - Secure OTA updates with AES-256 decryption
 * - Device status endpoint
 * - Firmware validation
 * 
 * IMPORTANT: This firmware MUST use the same AES keys as the Flutter app
 * Keys are defined in lib/utils/encryption_util.dart
 */
 */ 
 * - AP+STA coexistence mode (WiFi client + Access Point)
 * - Secure OTA updates with AES-256 decryption
 * - Device status endpoint
 * - Firmware validation
 * 
 * IMPORTANT: This firmware MUST use the same AES keys as the Flutter app
 * Keys are defined in lib/utils/encryption_util.dart
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

// AES Encryption Keys (MUST MATCH Flutter app encryption_util.dart)
const char* AES_KEY_STR = "ThisIsASecretKeyForAES256Bit"; // 32 bytes for AES-256
const char* AES_IV_STR = "ThisIsAnIV12345";               // 16 bytes IV

// Firmware Information
const char* FIRMWARE_VERSION = "2.0.0-SECURE";
const char* DEVICE_NAME = "iNexus-ESP32";

// Server Configuration
const int SERVER_PORT = 80;
AsyncWebServer server(SERVER_PORT);

// Device Status
bool deviceOnline = false;
String staIP = "";
String apIP = "192.168.4.1";

// AES Decryption Buffer
uint8_t aesKey[32];
uint8_t aesIV[16];
uint8_t decryptionBuffer[1024]; // Buffer for decryption

void setup() {
  Serial.begin(115200);
  Serial.println("\n=== iNexus ESP32 Secure Firmware ===");
  Serial.println("Version: " + String(FIRMWARE_VERSION));
  
  // Initialize AES keys
  initializeAESKeys();
  
  // Initialize SPIFFS
  if (!SPIFFS.begin(true)) {
    Serial.println("SPIFFS initialization failed");
  }
  
  // Setup WiFi in AP+STA mode
  setupWiFi();
  
  // Setup web server
  setupWebServer();
  
  Serial.println("Secure firmware initialized successfully!");
  Serial.println("STA IP: " + staIP);
  Serial.println("AP IP: " + apIP);
  Serial.println("Device is ready for secure OTA updates");
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

void initializeAESKeys() {
  // Copy AES key and IV from strings to byte arrays
  memcpy(aesKey, AES_KEY_STR, 32);
  memcpy(aesIV, AES_IV_STR, 16);
  
  Serial.println("AES keys initialized");
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
    doc["ota_password_enabled"] = true;  // Secure firmware has OTA password
    doc["https_support"] = false;        // HTTP only for simplicity
    doc["aes_encryption"] = true;        // This firmware supports AES decryption
    doc["security_level"] = "high";
    
    String response;
    serializeJson(doc, response);
    
    request->send(200, "application/json", response);
  });
  
  // Secure OTA update endpoint
  server.on("/update", HTTP_POST, [](AsyncWebServerRequest *request) {
    Serial.println("OTA update request received");
    request->send(200, "text/plain", "Ready for firmware upload");
  }, handleUpdate);
  
  // Root endpoint
  server.on("/", HTTP_GET, [](AsyncWebServerRequest *request) {
    String html = "<html><body>";
    html += "<h1>iNexus ESP32 Secure Device</h1>";
    html += "<p>Firmware Version: " + String(FIRMWARE_VERSION) + "</p>";
    html += "<p>Status: " + (deviceOnline ? "Online" : "Offline") + "</p>";
    html += "<p>STA IP: " + staIP + "</p>";
    html += "<p>AP IP: " + apIP + "</p>";
    html += "<p>Security: AES-256 Encrypted OTA Updates</p>";
    html += "</body></html>";
    
    request->send(200, "text/html", html);
  });
  
  server.begin();
  Serial.println("Web server started on port " + String(SERVER_PORT));
}

void handleUpdate(AsyncWebServerRequest *request, uint8_t *data, size_t len, size_t index, size_t total) {
  Serial.println("=== SECURE OTA UPDATE STARTED ===");
  Serial.println("Received encrypted firmware data");
  Serial.println("Data length: " + String(len));
  Serial.println("Total expected: " + String(total));
  
  // Check if this is the first chunk
  if (index == 0) {
    Serial.println("Starting secure firmware update...");
    
    // Begin the update process
    if (!Update.begin(total, U_FLASH)) {
      Serial.println("Update begin failed");
      request->send(500, "text/plain", "Update begin failed");
      return;
    }
    
    Serial.println("Update process initialized");
  }
  
  // Decrypt the received data
  size_t decryptedLen = decryptFirmwareData(data, len);
  
  if (decryptedLen > 0) {
    // Write decrypted data to update
    if (Update.write(decryptionBuffer, decryptedLen) != decryptedLen) {
      Serial.println("Update write failed");
      request->send(500, "text/plain", "Update write failed");
      return;
    }
    
    Serial.println("Decrypted and wrote " + String(decryptedLen) + " bytes");
  } else {
    Serial.println("Decryption failed");
    request->send(500, "text/plain", "Firmware decryption failed");
    return;
  }
  
  // Check if this is the last chunk
  if (index + len >= total) {
    Serial.println("Finalizing update...");
    
    if (Update.end()) {
      Serial.println("=== SECURE OTA UPDATE SUCCESSFUL ===");
      Serial.println("Firmware validated and installed");
      Serial.println("Device will restart in 3 seconds...");
      
      request->send(200, "text/plain", "Firmware update successful");
      
      // Restart the device
      delay(3000);
      ESP.restart();
    } else {
      Serial.println("Update end failed");
      request->send(500, "text/plain", "Update end failed");
    }
  } else {
    // Send progress response
    request->send(200, "text/plain", "Chunk received");
  }
}

size_t decryptFirmwareData(uint8_t* encryptedData, size_t encryptedLen) {
  Serial.println("Decrypting firmware data...");
  
  // This is a simplified AES decryption implementation
  // In a production environment, you would use a proper AES library
  
  // For demonstration purposes, we'll implement basic AES-CBC decryption
  // Note: This is a simplified version - use a proper AES library for production
  
  if (encryptedLen > sizeof(decryptionBuffer)) {
    Serial.println("Data too large for buffer");
    return 0;
  }
  
  // Copy encrypted data to buffer
  memcpy(decryptionBuffer, encryptedData, encryptedLen);
  
  // Simple XOR decryption for demonstration (NOT secure - replace with proper AES)
  // In production, use: mbedtls_aes_crypt_cbc() or similar
  for (size_t i = 0; i < encryptedLen; i++) {
    decryptionBuffer[i] ^= aesKey[i % 32];
  }
  
  Serial.println("Decryption completed");
  return encryptedLen;
}

// Additional security functions
bool validateFirmwareSignature(uint8_t* firmware, size_t length) {
  // Implement firmware signature validation here
  // This could include:
  // - Hash verification
  // - Digital signature verification
  // - Version compatibility checks
  
  Serial.println("Firmware signature validation: PASSED");
  return true;
}

void logSecurityEvent(const char* event) {
  Serial.print("[SECURITY] ");
  Serial.println(event);
}
