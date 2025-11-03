# DeviceCheck Sample Application

A comprehensive sample application demonstrating Apple's DeviceCheck API, including Device Identification and App Attest features.

## Project Structure

This repository contains two main components:

- **DeviceCheckApp**: iOS test application built with SwiftUI
- **DeviceCheckServer**: Backend server built with Swift and Vapor

## Requirements

### iOS App
- Xcode 15.0 or later
- iOS 17.0 or later
- Swift 5.9 or later

### Server
- Swift 5.9 or later
- macOS 13.0 or later (for development)

## Getting Started

### 1. Configure the Server

Before running the server, you need to configure your Apple credentials:

1. Open `DeviceCheckServer/Sources/App/Constants.swift`
2. Update the following constants:
   ```swift
   static let bundleID = "com.yourcompany.DeviceCheck"  // Your app's bundle ID
   static let teamID = "YOUR_TEAM_ID"                   // Your Apple Team ID
   static let authKeyID = "YOUR_KEY_ID"                 // Your Auth Key ID
   ```

3. For production use with Apple's DeviceCheck API:
   - Generate an authentication key in Apple Developer Portal
   - Download the `.p8` key file
   - Place it in the `DeviceCheckServer` directory
   - Update `authKeyPath` in Constants.swift if needed

### 2. Running the Server

Navigate to the server directory and run:

```bash
cd DeviceCheckServer
swift run
```

The server will start on `http://localhost:8080`

#### Available Endpoints

**Health Check:**
- `GET /` - Server info
- `GET /health` - Health status

**Device Identification:**
- `POST /api/device/query` - Query device bits
- `POST /api/device/update` - Update device bits
- `POST /api/device/validate` - Validate device

**App Attest:**
- `GET /api/attest/challenge` - Get attestation challenge
- `POST /api/attest/validate` - Validate attestation
- `POST /api/attest/assertion` - Validate assertion

### 3. Running the iOS App

1. Open `DeviceCheckApp/DeviceCheck.xcodeproj` in Xcode
2. Update the bundle identifier to match your Apple Developer account
3. Select a physical device (DeviceCheck requires a real device, not simulator)
4. Make sure the server is running
5. Build and run the app (⌘R)

**Note:** DeviceCheck APIs only work on physical iOS devices, not in the simulator.

### 4. Configure Backend Endpoint for iPhone Access

To access the server from your iPhone, you need to configure the iOS app to use your Mac's local IP address instead of `localhost`.

#### Step 1: Find Your Mac's Local IP Address

1. Open **System Settings** (or **System Preferences** on older macOS)
2. Go to **Network**
3. Select your active Wi-Fi connection
4. Note your **IP Address** (e.g., `192.168.1.100`)

Alternatively, use Terminal:
```bash
ipconfig getifaddr en0
```
(Replace `en0` with your active network interface if different)

#### Step 2: Ensure Both Devices Are on the Same Network

Make sure your iPhone and Mac are connected to the same Wi-Fi network.

#### Step 3: Update the iOS App Configuration

1. Open `DeviceCheckApp/DeviceCheckApp/Constants.swift`
2. Replace `localhost` with your Mac's IP address:
   ```swift
   static let baseURL = "http://192.168.1.100:8080"
   ```
   (Replace `192.168.1.100` with your actual IP address)

#### Step 4: Configure Firewall (if needed)

If your Mac's firewall blocks incoming connections:

1. Open **System Settings** → **Network** → **Firewall**
2. Click **Options** or **Firewall Options**
3. Ensure incoming connections are allowed for the Vapor server, or temporarily disable the firewall for testing

#### Alternative: Using a Different Machine or Port

If running the server on a different machine or port, update `baseURL` accordingly:
   ```swift
   static let baseURL = "http://your-server-address:8080"
   ```

## Features

### Device Identification Tab

The Device Identification tab demonstrates Apple's two-bit storage API:

- **Query Request**: Retrieves the current values of the two bits from Apple's servers
- **Update Request**: Updates the two bits with new values
- **Device Validation**: Validates the device against custom criteria

The UI displays the bits as gray rounded squares that show 0 or 1 when populated.

### App Attest Tab

The App Attest tab is a placeholder for App Attest functionality. The server includes endpoints for:

- Challenge generation
- Attestation validation
- Assertion validation

## Demo Mode

**Important:** The current implementation runs in **demo mode**. The server simulates responses from Apple's DeviceCheck API without making actual calls to Apple's servers.

To integrate with Apple's real DeviceCheck API:

1. Configure your Apple Developer account credentials
2. Implement JWT token generation for Apple API authentication
3. Update the controller methods to make actual HTTP requests to Apple's DeviceCheck endpoints
4. Add proper CBOR parsing for App Attest attestation and assertion objects
5. Implement cryptographic verification of App Attest signatures

## Architecture

### iOS App
- **SwiftUI** for the user interface
- **MVVM** architecture with view models
- **DeviceCheck** framework for device token generation
- **App Attest** framework for attestation (placeholder)

### Server
- **Vapor** web framework
- **Controller-based** routing
- Separate controllers for Device Identification and App Attest
- **Models** for request/response objects

## Development

### Building for Production

For production deployment:

1. Update server configuration in `configure.swift`
2. Configure proper authentication with Apple's API
3. Add database persistence for storing device states and public keys
4. Implement proper error handling and logging
5. Add rate limiting and security measures
6. Use HTTPS for all communications

### Testing

Run server tests:
```bash
cd DeviceCheckServer
swift test
```

## Resources

- [Apple DeviceCheck Documentation](https://developer.apple.com/documentation/devicecheck)
- [App Attest Documentation](https://developer.apple.com/documentation/devicecheck/validating_apps_that_connect_to_your_server)
- [Vapor Documentation](https://docs.vapor.codes)

## License

See LICENSE.txt for details.

## Notes

- DeviceCheck is only available on physical iOS devices (iOS 11.0+)
- App Attest requires iOS 14.0 or later
- The two-bit storage is device-specific and persists across app installations
- Proper implementation requires server-side verification with Apple's servers

