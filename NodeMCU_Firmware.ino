#include <ESP8266WiFi.h>
#include <WiFiClientSecureBearSSL.h>
#include <PubSubClient.h>
#include <ArduinoOTA.h>
#include <ESP8266WebServer.h>
#include <ESP8266HTTPUpdateServer.h>
#include <Ticker.h>
#include <ArduinoJson.h>

// ===== User Configuration =====
constexpr char WIFI_SSID[] = "realme 10 Pro+ 5G";           // Replace with your WiFi name
constexpr char WIFI_PASSWORD[] = "00000000";   // Replace with your WiFi password
constexpr char MQTT_HOST[] = "broker.hivemq.com";        // Free HiveMQ broker
constexpr uint16_t MQTT_PORT = 1883;                     // Non-TLS port (easier for testing)
constexpr char MQTT_USERNAME[] = "";                      // No username needed for HiveMQ
constexpr char MQTT_PASSWORD[] = "";                      // No password needed for HiveMQ
constexpr char OTA_PASSWORD[] = "strong-ota-password";    // Password for OTA updates
constexpr char DEVICE_ID[] = "nmc-01";                    // Unique device identifier

// MQTT Topics
constexpr char TOPIC_PUB[] = "devices/nodemcu/nmc-01/telemetry";
constexpr char TOPIC_SUB[] = "devices/nodemcu/nmc-01/cmd";
constexpr char TOPIC_STATUS[] = "devices/nodemcu/nmc-01/status";

// ===== Global Variables =====
PubSubClient mqtt;
ESP8266WebServer httpServer(80);
Ticker telemetryTicker;
Ticker statusTicker;

// Device status
bool deviceOnline = false;
unsigned long lastTelemetry = 0;
unsigned long lastStatusUpdate = 0;
unsigned long wifiReconnectAttempts = 0;
unsigned long mqttReconnectAttempts = 0;

// ===== Utility Functions =====
void secureDelay(uint32_t ms) {
  // Yield-friendly delay to keep WiFi/MQTT alive and WDT fed
  uint32_t start = millis();
  while (millis() - start < ms) {
    yield();
    delay(1);
  }
}

void logMessage(const String& message) {
  Serial.print("[");
  Serial.print(millis());
  Serial.print("] ");
  Serial.println(message);
}

// ===== WiFi Functions =====
void setupWiFi() {
  logMessage("Setting up WiFi...");
  
  WiFi.mode(WIFI_STA);
  WiFi.persistent(false); // Avoid storing creds in flash repeatedly
  WiFi.setAutoReconnect(true);
  WiFi.setSleep(false); // Better stability for MQTT
  
  WiFi.begin(WIFI_SSID, WIFI_PASSWORD);
  
  uint32_t start = millis();
  while (WiFi.status() != WL_CONNECTED) {
    secureDelay(250);
    if (millis() - start > 30000) { // 30s timeout
      logMessage("WiFi connection timeout, restarting...");
      ESP.restart();
    }
  }
  
  logMessage("WiFi connected! IP: " + WiFi.localIP().toString());
  deviceOnline = true;
  wifiReconnectAttempts = 0;
}

void ensureWiFi() {
  if (WiFi.status() != WL_CONNECTED) {
    logMessage("WiFi disconnected, reconnecting...");
    deviceOnline = false;
    wifiReconnectAttempts++;
    
    if (wifiReconnectAttempts > 10) {
      logMessage("Too many WiFi reconnect attempts, restarting...");
      ESP.restart();
    }
    
    setupWiFi();
  }
}

// ===== Time Functions =====
void ensureTime() {
  // TLS needs correct time for cert validation
  configTime(0, 0, "pool.ntp.org", "time.google.com");
  
  time_t now = time(nullptr);
  uint32_t start = millis();
  
  while (now < 1700000000) { // ~2023-11-14
    secureDelay(200);
    now = time(nullptr);
    if (millis() - start > 15000) break; // Don't block forever
  }
  
  if (now > 1700000000) {
    logMessage("Time synchronized: " + String(now));
  } else {
    logMessage("Time sync failed, continuing anyway...");
  }
}

// ===== MQTT Functions =====
void mqttCallback(char const* topic, byte* payload, unsigned int len) {
  // Handle incoming MQTT commands
  String cmd;
  cmd.reserve(len);
  for (unsigned int i = 0; i < len; i++) {
    cmd += (char)payload[i];
  }
  
  logMessage("MQTT command received: " + cmd);
  
  // Handle different commands
  if (cmd == "ping") {
    String msg = "{\"device\":\"" + String(DEVICE_ID) + "\",\"pong\":true}";
    mqtt.publish(TOPIC_PUB, msg.c_str(), true);
  } else if (cmd == "restart") {
    logMessage("Restart command received, restarting...");
    delay(1000);
    ESP.restart();
  } else if (cmd == "status") {
    publishStatus();
  }
  
  (void)topic; // Suppress unused parameter warning
}

bool mqttConnect() {
  logMessage("Connecting to MQTT broker...");
  
  mqtt.setServer(MQTT_HOST, MQTT_PORT);
  mqtt.setCallback(mqttCallback);
  
  // Use regular WiFi client for non-TLS connection
  WiFiClient client;
  mqtt.setClient(client);
  
  // Randomize clientId to avoid collisions
  String cid = String(DEVICE_ID) + "-" + String(ESP.getChipId(), HEX);
  
  // Connect with optional authentication
  bool connected;
  if (strlen(MQTT_USERNAME) > 0 && strlen(MQTT_PASSWORD) > 0) {
    connected = mqtt.connect(cid.c_str(), MQTT_USERNAME, MQTT_PASSWORD);
  } else {
    connected = mqtt.connect(cid.c_str());
  }
  
  if (connected) {
    logMessage("MQTT connected successfully!");
    mqtt.subscribe(TOPIC_SUB);
    
    // Publish online status
    String statusMsg = "{\"device\":\"" + String(DEVICE_ID) + "\",\"status\":\"online\",\"ip\":\"" + WiFi.localIP().toString() + "\"}";
    mqtt.publish(TOPIC_STATUS, statusMsg.c_str(), true);
    
    mqttReconnectAttempts = 0;
    return true;
  } else {
    logMessage("MQTT connection failed, error: " + String(mqtt.state()));
    return false;
  }
}

void ensureMQTT() {
  if (!mqtt.connected()) {
    logMessage("MQTT disconnected, reconnecting...");
    mqttReconnectAttempts++;
    
    if (mqttReconnectAttempts > 5) {
      logMessage("Too many MQTT reconnect attempts, restarting...");
      ESP.restart();
    }
    
    mqttConnect();
  }
}

// ===== Telemetry Functions =====
void publishTelemetry() {
  if (!mqtt.connected()) return;
  
  // Create telemetry data
  JsonDocument doc;
  doc["device"] = DEVICE_ID;
  doc["timestamp"] = millis();
  doc["rssi"] = WiFi.RSSI();
  doc["heap"] = ESP.getFreeHeap();
  doc["uptime"] = millis();
  doc["ip"] = WiFi.localIP().toString();
  doc["mac"] = WiFi.macAddress();
  
  String payload;
  serializeJson(doc, payload);
  
  if (mqtt.publish(TOPIC_PUB, payload.c_str(), true)) {
    lastTelemetry = millis();
    logMessage("Telemetry published: " + payload);
  } else {
    logMessage("Failed to publish telemetry");
  }
}

void publishStatus() {
  if (!mqtt.connected()) return;
  
  JsonDocument doc;
  doc["device"] = DEVICE_ID;
  doc["status"] = deviceOnline ? "online" : "offline";
  doc["ip"] = WiFi.localIP().toString();
  doc["rssi"] = WiFi.RSSI();
  doc["heap"] = ESP.getFreeHeap();
  doc["uptime"] = millis();
  
  String payload;
  serializeJson(doc, payload);
  
  mqtt.publish(TOPIC_STATUS, payload.c_str(), true);
}

// ===== OTA Functions =====
void setupOTA() {
  logMessage("Setting up OTA...");
  
  ArduinoOTA.setHostname(DEVICE_ID);
  ArduinoOTA.setPassword(OTA_PASSWORD);
  
  ArduinoOTA.onStart([]() {
    logMessage("OTA update started");
    deviceOnline = false;
  });
  
  ArduinoOTA.onEnd([]() {
    logMessage("OTA update completed");
  });
  
  ArduinoOTA.onProgress([](unsigned int progress, unsigned int total) {
    int percent = (progress / (total / 100));
    logMessage("OTA progress: " + String(percent) + "%");
  });
  
  ArduinoOTA.onError([](ota_error_t error) {
    logMessage("OTA error: " + String(error));
  });
  
  ArduinoOTA.begin();
}

// ===== HTTP Server Functions =====
void setupHTTPServer() {
  logMessage("Setting up HTTP server...");
  
  // Status endpoint
  httpServer.on("/status", HTTP_GET, []() {
    JsonDocument doc;
    doc["device"] = DEVICE_ID;
    doc["status"] = deviceOnline ? "online" : "offline";
    doc["ip"] = WiFi.localIP().toString();
    doc["rssi"] = WiFi.RSSI();
    doc["heap"] = ESP.getFreeHeap();
    doc["uptime"] = millis();
    doc["mac"] = WiFi.macAddress();
    doc["ssid"] = WiFi.SSID();
    doc["mqtt_connected"] = mqtt.connected();
    
    String response;
    serializeJson(doc, response);
    
    httpServer.sendHeader("Access-Control-Allow-Origin", "*");
    httpServer.sendHeader("Content-Type", "application/json");
    httpServer.send(200, "application/json", response);
  });
  
  // Root endpoint
  httpServer.on("/", HTTP_GET, []() {
    String html = "<!DOCTYPE html><html><head><title>";
    html += DEVICE_ID;
    html += "</title></head><body><h1>NodeMCU Device: ";
    html += DEVICE_ID;
    html += "</h1><p>Status: ";
    html += (deviceOnline ? "Online" : "Offline");
    html += "</p><p>IP: ";
    html += WiFi.localIP().toString();
    html += "</p><p>RSSI: ";
    html += String(WiFi.RSSI());
    html += " dBm</p><p>Free Heap: ";
    html += String(ESP.getFreeHeap());
    html += " bytes</p><p>Uptime: ";
    html += String(millis() / 1000);
    html += " seconds</p><p>MQTT: ";
    html += (mqtt.connected() ? "Connected" : "Disconnected");
    html += "</p></body></html>";
    
    httpServer.send(200, "text/html", html);
  });
  
  // 404 handler
  httpServer.onNotFound([]() {
    httpServer.send(404, "text/plain", "Not Found");
  });
  
  httpServer.begin();
  logMessage("HTTP server started on port 80");
}

// ===== Main Functions =====
void setup() {
  // Initialize serial
  Serial.begin(115200);
  Serial.println();
  logMessage("NodeMCU starting up...");
  
  // Watchdog
  ESP.wdtDisable();
  ESP.wdtEnable(8000);
  
  // Stronger RNG seed
  randomSeed(os_random());
  
  // Setup WiFi
  setupWiFi();
  
  // Ensure time for TLS
  ensureTime();
  
  // Setup OTA
  setupOTA();
  
  // Setup HTTP server
  setupHTTPServer();
  
  // Connect to MQTT
  if (!mqttConnect()) {
    logMessage("Initial MQTT connection failed, will retry in loop");
  }
  
  // Setup timers
  telemetryTicker.attach_ms(30000, []() { publishTelemetry(); }); // Every 30 seconds
  statusTicker.attach_ms(60000, []() { publishStatus(); });       // Every 60 seconds
  
  logMessage("Setup complete!");
}

void loop() {
  // Feed watchdog
  ESP.wdtFeed();
  
  // Handle OTA updates
  ArduinoOTA.handle();
  
  // Ensure WiFi connection
  ensureWiFi();
  
  // Ensure MQTT connection
  ensureMQTT();
  
  // Handle MQTT
  mqtt.loop();
  
  // Handle HTTP requests
  httpServer.handleClient();
  
  // Small delay to keep system responsive
  secureDelay(10);
}
