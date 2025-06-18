# iNexus: Secure Local IoT Device Management

![iNexus Dashboard Screenshot](https://placehold.co/800x500/32CD32/FFFFFF/PNG?text=iNexus+App+Screenshot+Here)
*(Replace this placeholder with an actual screenshot of your iNexus app dashboard)*

## 🚀 Overview

iNexus is a mobile-first, responsive Flutter application designed to provide a secure and intuitive way to manage Internet of Things (IoT) devices locally over Wi-Fi. It addresses common challenges in IoT device management, such as manual status checks, insecure firmware updates, and fragmented control tools.

The project demonstrates real-time device status monitoring and a foundational secure Over-The-Air (OTA) firmware update mechanism, highlighting the transition from an "unsecure" firmware to a "secure" one via client-side AES-256 encryption.

## ✨ Features

### Flutter Application (Client)
* **Device Connection:** Connects to NodeMCU/ESP32 devices using IP address and Port over local Wi-Fi.
* **Real-time Status:** Displays device online/offline status.
* **Device Information:** Shows connected device's IP address, current firmware version, and OTA capability status.
* **Security Status:** Indicates device-reported security features (e.g., OTA password enabled, HTTPS support).
* **Secure Firmware Upload:** Allows selection and upload of `.bin` firmware files.
* **Client-Side Encryption:** Encrypts firmware files using AES-256 before transmission.
* **Update Status:** Provides success/failure feedback for firmware uploads, including simulated validity checks.
* **Recent Connections:** Stores and allows quick access to recently connected device IP addresses.
* **User Interface:** Clean, responsive dashboard with a dark/light theme toggle.

### NodeMCU/ESP8266 Firmware (Device)
* **AP+STA Coexistence Mode:** Operates simultaneously as a Wi-Fi client (connecting to home Wi-Fi) and an Access Point (creating its own hotspot).
* **Web Server:** Hosts a simple HTTP server on port 80.
* **`/status` Endpoint:** Responds with device information (IP, firmware version, OTA status, security flags) in JSON format.
* **`/update` Endpoint:** Receives and processes `.bin` firmware files via HTTP POST for OTA updates.
* **Firmware Versions (for Demo):**
    * **Unsecure Firmware:** Accepts encrypted updates but **does not decrypt or validate**, flashing raw encrypted data. Reports `ota_password_enabled: false`.
    * **Secure Firmware:** Accepts encrypted updates, includes placeholders for **AES decryption and firmware validation**. Reports `ota_password_enabled: true`.

## 💻 Technology Stack

* **Flutter (Dart):** Mobile-first, cross-platform application development.
* **NodeMCU / ESP8266 (C++/Arduino Framework):** Embedded device firmware.
* **`http` package (Dart):** For real network communication.
* **`encrypt` package (Dart):** For client-side AES-256 encryption.
* **`AESLib` library (C++):** For AES encryption/decryption on NodeMCU.
* **`shared_preferences` (Flutter):** Local storage for app preferences.
* **`file_picker` (Flutter):** For file selection on mobile devices.
* **`flutter_spinkit`, `fluttertoast` (Flutter):** UI enhancements and feedback.
* **Git & GitHub:** Version control and collaboration.

## ⚙️ Getting Started

### Prerequisites

* [Flutter SDK](https://flutter.dev/docs/get-started/install) installed and configured.
* [Arduino IDE](https://www.arduino.cc/en/software) or [PlatformIO (VS Code Extension)](https://platformio.org/) installed.
* ESP8266 board (e.g., NodeMCU ESP-12E) with a data-capable USB cable.
* ESP8266 Board Core installed in Arduino IDE:
    * Go to `File > Preferences > Additional Boards Manager URLs` and add: `http://arduino.esp8266.com/stable/package_esp8266com_index.json`
    * Go to `Tools > Board > Boards Manager...`, search "esp8266" and install "esp8266 by ESP8266 Community".
* `AESLib` library installed in Arduino IDE:
    * Go to `Sketch > Include Library > Manage Libraries...`, search for "AESLib" by sivann and install it.

### 1. Flutter Application Setup

1.  **Clone the repository:**
    ```bash
    git clone [https://github.com/your-username/iNexus.git](https://github.com/your-username/iNexus.git) # Replace with your repo URL
    cd iNexus
    ```
2.  **Ensure correct project name in imports:** If you cloned/copied the project, ensure all internal imports use `package:safex2/`.
    * In your IDE (VS Code/Android Studio), perform a global find and replace:
        * Find: `package:old_project_name/` (e.g., `package:imeter_app/`)
        * Replace with: `package:safex2/`
    * Do this across all `.dart` files in the `lib/` directory.
3.  **Install dependencies:**
    ```bash
    flutter pub get
    ```
4.  **Configure Android Permissions (if targeting Android mobile):**
    * Open `android/app/src/main/AndroidManifest.xml`.
    * Add the following permissions inside the `<manifest>` tag, but *outside* the `<application>` tag:
        ```xml
        <uses-permission android:name="android.permission.INTERNET"/>
        <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE"/>
        <uses-permission android:name="android.permission.ACCESS_WIFI_STATE"/>
        <uses-permission android:name="android.permission.CHANGE_WIFI_STATE"/>
        <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE"/>
        <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" android:maxSdkVersion="32"/>
        <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" android:maxSdkVersion="29"/>
        ```
5.  **Configure Android NDK Version (if targeting Android mobile):**
    * Open `android/app/build.gradle.kts`.
    * Inside the `android { ... }` block, ensure `ndkVersion` is explicitly set (this often resolves plugin compatibility issues):
        ```kotlin
        ndkVersion = "27.0.12077973" // Or the highest NDK version required by your plugins
        ```
    * Also, ensure Java compatibility is set to 11:
        ```kotlin
        compileOptions {
            sourceCompatibility = JavaVersion.VERSION_11
            targetCompatibility = JavaVersion.VERSION_11
        }
        ```
6.  **Clean and run:**
    ```bash
    flutter clean
    flutter run # or flutter run -d chrome for web
    ```

### 2. NodeMCU Firmware Setup

This project uses two firmware versions to demonstrate the OTA security upgrade.

#### a. Initial "Unsecure" Firmware (Flash via USB)

This is the firmware you will flash to your ESP8266 **first, via USB**. It allows OTA but doesn't decrypt or validate updates.

1.  **Open the sketch:** Create a new sketch in Arduino IDE and paste the content of `iMeter_NodeMCU_AP_STA_Unsecure_Firmware.ino`.
2.  **Customize Wi-Fi:**
    * Replace `YOUR_HOME_WIFI_SSID` and `YOUR_HOME_WIFI_PASSWORD` with your actual home Wi-Fi credentials.
    * Optionally, customize `ap_ssid` and `ap_password` for your NodeMCU's hotspot.
3.  **Select Board & Port:** Go to `Tools > Board > ESP8266 Boards` and select your specific NodeMCU model (e.g., "NodeMCU 1.0 (ESP-12E Module)"). Select the correct serial port under `Tools > Port`.
4.  **Upload:** Click the "Upload" button. If it gets stuck on "Connecting...", press and hold the "FLASH/BOOT" button on your NodeMCU, briefly press "RST/EN", then release "FLASH/BOOT" when "Writing at..." appears.
5.  **Get IP:** After successful upload, open the Serial Monitor (115200 baud). Reset the NodeMCU. Note the **"STA IP Address"** (e.g., `192.168.1.XXX`).

#### b. Target "Secure" Firmware (Compile to .bin for OTA)

This is the firmware you will compile into a `.bin` file and upload using the Flutter app. It includes the AES decryption and validation placeholders.

1.  **Open the sketch:** Create a new sketch in Arduino IDE and paste the content of `iMeter_NodeMCU_AP_STA_Secure_Firmware.ino`.
2.  **Customize Wi-Fi & Keys:**
    * Use the **same home Wi-Fi credentials** (`sta_ssid`, `sta_password`) as the unsecure firmware.
    * **Crucially:** The `AES_KEY_STR` and `AES_IV_STR` must **EXACTLY MATCH** those hardcoded in your Flutter app's `lib/utils/encryption_util.dart`.
3.  **Implement AES Decryption (Required for Actual Security):**
    * In the `handleUpdate()` function, locate the `--- CRITICAL AES DECRYPTION IMPLEMENTATION ---` block.
    * **You MUST replace the placeholder code here with actual AES decryption logic** using the `AESLib` methods (e.g., `aes.cbc_decrypt`). This is complex and involves careful handling of input buffers, decrypted output, and potentially padding for the last block of the file.
4.  **Compile to .bin:** Go to `Sketch > Export compiled Binary`. This will create a `.bin` file in your sketch's folder. **DO NOT UPLOAD THIS VIA USB.**

## 🚀 Demonstration & Usage

This process demonstrates upgrading from the unsecure firmware to the secure firmware via the Flutter app.

1.  **Initial State (Unsecure FW on Device):**
    * Ensure your NodeMCU is running the **"Unsecure" firmware** (flashed via USB).
    * Ensure your phone/computer running the Flutter app is connected to the **same home Wi-Fi network** as the NodeMCU.
    * In the Flutter app, enter the NodeMCU's **STA IP Address** (e.g., `192.168.1.XXX`) and port `80`. Click "Connect".
    * **App Status:** The app should display **"OTA Update: Enabled"** and **"OTA Password: Disabled"** (reflecting the unsecure firmware).

2.  **Perform OTA Update (Unsecure -> Secure):**
    * In the Flutter app, click **"Upload Firmware (.bin)"**.
    * Select the **`.bin` file of the "Secure" firmware** (compiled in section 2b).
    * **Observe:**
        * **App:** Shows upload progress.
        * **NodeMCU Serial Monitor:** You'll see "OTA Update (Unsecure FW): Start receiving file..." and progress. Since the Unsecure firmware doesn't decrypt, it flashes the encrypted data directly.
        * **Outcome:** The NodeMCU will likely **fail to boot correctly or enter a boot loop** because it's running corrupted (encrypted) firmware. This highlights the risk of unsecure updates.

3.  **Restore Device (Manual Flash to Secure FW):**
    * To get the device working with the secure firmware, **you MUST manually flash the `iMeter_NodeMCU_AP_STA_Secure_Firmware.ino` sketch to your ESP8266 via USB.**

4.  **Verify Secure State (on Device):**
    * After the manual flash of the Secure Firmware, reset the NodeMCU. Get its new STA IP from the Serial Monitor.
    * Connect your Flutter app to this STA IP.
    * **App Status:** The app should now display **"OTA Update: Enabled"** and **"OTA Password: Enabled"** (reflecting the secure firmware).

5.  **Test Secure OTA (Optional, for full validation):**
    * Compile a *slightly modified* version of the Secure firmware into a new `.bin` file.
    * Upload this new `.bin` file from the Flutter app to the NodeMCU (which is now running the secure firmware).
    * **Observe:**
        * If your AES decryption and validation logic is **correctly implemented** in the Secure firmware, the app will report "Firmware update successful" and **"Firmware Validity: valid and secure"**.
        * If decryption/validation fails (e.g., incorrect keys, corrupted file, incomplete decryption logic), the app will report "Firmware update failed" and **"Firmware Validity: invalid or insecure"**.

## 🛡️ Security Considerations

* **AES-256 Encryption:** Firmware files are encrypted client-side by the Flutter app.
* **Device-Side Decryption & Validation:** The "Secure" firmware includes placeholders for AES decryption and integrity validation (e.g., hash checks). **Proper implementation of this is critical for actual security.**
* **Hardcoded Keys (Development Only):** The AES keys and IVs are hardcoded in both the app and the firmware. **This is highly insecure for production environments.** A secure key management strategy must be implemented for a production-ready application.

## 👥 Team Members (Group E12)

* Atharva Shevate
* Ayush Herkal
* Pranav Karanjkar
* Atharva Lohote
* Adiraj Chinchpure

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).
