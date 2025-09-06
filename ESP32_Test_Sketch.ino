/*
 * ESP32 Minimal Test Sketch
 * This is a simple test to verify upload works
 */

void setup() {
  Serial.begin(115200);
  Serial.println("ESP32 Test Sketch - Upload Successful!");
  Serial.println("If you see this, the upload worked!");
}

void loop() {
  Serial.println("ESP32 is running...");
  delay(1000);
}
