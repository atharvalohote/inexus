#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>

// WiFi Configuration
const char* ssid = "realme 10 Pro+ 5G";
const char* password = "00000000";

// HTTP server configuration
const uint16_t SERVER_PORT = 80;
ESP8266WebServer server(SERVER_PORT);

void setup() {
  Serial.begin(115200);
  Serial.println();
  Serial.println("NodeMCU Simple Test Starting...");
  
  // Connect to WiFi
  WiFi.begin(ssid, password);
  Serial.print("Connecting to WiFi");
  
  while (WiFi.status() != WL_CONNECTED) {
    delay(500);
    Serial.print(".");
  }
  
  Serial.println();
  Serial.println("WiFi connected!");
  Serial.println("==================");
  Serial.print("IP address: ");
  Serial.println(WiFi.localIP());
  Serial.print("Port: ");
  Serial.println(SERVER_PORT);
  Serial.print("URL: http://");
  Serial.print(WiFi.localIP());
  Serial.print(":");
  Serial.println(SERVER_PORT);
  Serial.println("==================");
  
  // Print IP/Port prominently
  Serial.println();
  Serial.println("*** IMPORTANT: NODEMCU NETWORK DETAILS ***");
  Serial.print("*** IP: ");
  Serial.print(WiFi.localIP());
  Serial.print("  PORT: ");
  Serial.print(SERVER_PORT);
  Serial.println(" ***");
  Serial.println("*** Browse: http://" + WiFi.localIP().toString() + ":" + String(SERVER_PORT) + " ***");
  Serial.println("*******************************************");
  Serial.println();
  
  // Also print in simple lines
  Serial.println("NODEMCU IP:");
  Serial.println(WiFi.localIP());
  Serial.println("NODEMCU PORT:");
  Serial.println(SERVER_PORT);
  Serial.println();
  
  // Setup web server
  server.on("/", handleRoot);
  server.on("/status", handleStatus);
  server.on("/test", handleTest);
  
  server.begin();
  Serial.println("HTTP server started");
  Serial.println("Setup complete!");
}

void loop() {
  server.handleClient();
  delay(10);
}

void handleRoot() {
  String html = "<html><head><title>NodeMCU Test</title></head>";
  html += "<body><h1>NodeMCU Simple Test</h1>";
  html += "<p>Status: <strong>Online</strong></p>";
  html += "<p>IP: " + WiFi.localIP().toString() + "</p>";
  html += "<p>Port: " + String(SERVER_PORT) + "</p>";
  html += "<p>RSSI: " + String(WiFi.RSSI()) + " dBm</p>";
  html += "<p>Free Heap: " + String(ESP.getFreeHeap()) + " bytes</p>";
  html += "<p>Uptime: " + String(millis() / 1000) + " seconds</p>";
  html += "<hr>";
  html += "<p><a href='/status'>JSON Status</a></p>";
  html += "<p><a href='/test'>Test Connection</a></p>";
  html += "</body></html>";
  
  server.send(200, "text/html", html);
}

void handleStatus() {
  String json = "{";
  json += "\"device\":\"nmc-test\",";
  json += "\"status\":\"online\",";
  json += "\"ip\":\"" + WiFi.localIP().toString() + "\",";
  json += "\"port\":" + String(SERVER_PORT) + ",";
  json += "\"rssi\":" + String(WiFi.RSSI()) + ",";
  json += "\"heap\":" + String(ESP.getFreeHeap()) + ",";
  json += "\"uptime\":" + String(millis() / 1000);
  json += "}";
  
  server.sendHeader("Access-Control-Allow-Origin", "*");
  server.send(200, "application/json", json);
}

void handleTest() {
  server.send(200, "text/plain", "Connection test successful! NodeMCU is working.");
}
