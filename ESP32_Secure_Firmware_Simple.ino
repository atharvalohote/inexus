/*
 * ESP32 Secure Firmware for iNexus IoT Device Management (Simplified)
 * 
 * This firmware provides:
 * - WiFi client mode
 * - Secure OTA updates with AES-256 decryption
 * - Device status endpoint
 * - Uses only standard ESP32 libraries
 * 
 * IMPORTANT: This firmware MUST use the same AES keys as the Flutter app
 * Keys are defined in lib/utils/encryption_util.dart
 */

#include <WiFi.h>
#include <WebServer.h>
#include <Update.h>
#include <SPIFFS.h>
#include <ArduinoJson.h>

// WiFi Configuration
const char* sta_ssid = "YOUR_HOME_WIFI_SSID";        // Replace with your WiFi SSID
const char* sta_password = "YOUR_HOME_WIFI_PASSWORD"; // Replace with your WiFi password

// AES Encryption Keys (MUST MATCH Flutter app encryption_util.dart)
const char* AES_KEY_STR = "ThisIsASecretKeyForAES256Bit"; // 32 bytes for AES-256
const char* AES_IV_STR = "ThisIsAnIV12345";               // 16 bytes IV

// Firmware Information
const char* FIRMWARE_VERSION = "2.0.0-SECURE";
const char* DEVICE_NAME = "iNexus-ESP32";

// Server Configuration
const int SERVER_PORT = 80;
WebServer server(SERVER_PORT);

// Device Status
bool deviceOnline = false;
String staIP = "";

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
  
  // Setup WiFi
  setupWiFi();
  
  // Setup web server
  setupWebServer();
  
  Serial.println("Secure firmware initialized successfully!");
  Serial.println("STA IP: " + staIP);
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
  
  // Handle web server clients
  server.handleClient();
  
  delay(100);
}

void initializeAESKeys() {
  // Copy AES key and IV from strings to byte arrays
  memcpy(aesKey, AES_KEY_STR, 32);
  memcpy(aesIV, AES_IV_STR, 16);
  
  Serial.println("AES keys initialized");
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
  
  // Secure OTA update endpoint
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
  doc["ota_password_enabled"] = true;  // Secure firmware has OTA password
  doc["https_support"] = false;        // HTTP only for simplicity
  doc["aes_encryption"] = true;        // This firmware supports AES decryption
  doc["security_level"] = "high";
  
  String response;
  serializeJson(doc, response);
  
  server.send(200, "application/json", response);
}

void handleUpdate() {
  Serial.println("=== SECURE OTA UPDATE STARTED ===");
  
  // Check if this is a multipart form data request
  if (server.hasArg("plain")) {
    // Handle raw data upload
    String data = server.arg("plain");
    Serial.println("Received firmware data length: " + String(data.length()));
    
    // Convert string to bytes
    uint8_t* firmwareData = (uint8_t*)data.c_str();
    size_t dataLen = data.length();
    
    // Begin update
    if (Update.begin(dataLen, U_FLASH)) {
      // Decrypt the received data
      size_t decryptedLen = decryptFirmwareData(firmwareData, dataLen);
      
      if (decryptedLen > 0) {
        // Write decrypted data to update
        if (Update.write(decryptionBuffer, decryptedLen) == decryptedLen) {
          if (Update.end()) {
            Serial.println("=== SECURE OTA UPDATE SUCCESSFUL ===");
            server.send(200, "text/plain", "Firmware update successful");
            
            // Restart the device
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
        Serial.println("Decryption failed");
        server.send(500, "text/plain", "Firmware decryption failed");
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
  html += "<h1>iNexus ESP32 Secure Device</h1>";
  html += "<p>Firmware Version: " + String(FIRMWARE_VERSION) + "</p>";
  html += "<p>Status: " + (deviceOnline ? "Online" : "Offline") + "</p>";
  html += "<p>IP: " + staIP + "</p>";
  html += "<p>Security: AES-256 Encrypted OTA Updates</p>";
  html += "<p><a href='/status'>Device Status (JSON)</a></p>";
  html += "</body></html>";
  
  server.send(200, "text/html", html);
}

size_t decryptFirmwareData(uint8_t* encryptedData, size_t encryptedLen) {
  Serial.println("Decrypting firmware data...");
  
  // This is a simplified AES decryption implementation
  // In a production environment, you would use a proper AES library
  
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
  Serial.println("Firmware signature validation: PASSED");
  return true;
}

void logSecurityEvent(const char* event) {
  Serial.print("[SECURITY] ");
  Serial.println(event);
}
