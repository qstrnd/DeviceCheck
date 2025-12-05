# DeviceCheck Sample Application

A comprehensive sample application demonstrating Apple's DeviceCheck API, including Device Identification and App Attest features.

![Demo video](DeviceCheckDemoVideo.gif)

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

Before running the server, you need to configure your Apple credentials.

#### Step 1: Create PrivateConstants.swift

Create a new file at `DeviceCheckServer/Sources/App/PrivateConstants.swift` with the following structure:

```swift
import Foundation

struct PrivateConstants {
    static let authKeyPath = "./Resources/AuthKey.p8"
    static let authKeyID = "YOUR_KEY_ID"
    static let teamID = "YOUR_TEAM_ID"
}
```

#### Step 2: Add Your Authentication Key

1. Go to [Apple Developer Portal - Keys](https://developer.apple.com/account/resources/authkeys/list)
2. Create a new key with **DeviceCheck** capability enabled
3. Download the `.p8` key file (⚠️ **You can only download it once!**)
4. Copy the downloaded file to `DeviceCheckServer/Resources/AuthKey.p8`

#### Step 3: Update Your Credentials

Open `DeviceCheckServer/Sources/App/PrivateConstants.swift` and fill in your actual values:

**Finding Your Credentials:**

- **`authKeyID`** (Key ID): Your 10-character Key ID
  - **Location 1:** Apple Developer Portal > Certificates, Identifiers & Profiles > Keys
  - **Location 2:** In the filename of your downloaded .p8 file: `AuthKey_<KEY_ID>.p8`
  - **Format:** 10-character string (e.g., `ABC123DEFG`)

- **`teamID`** (Team ID): Your 10-character Team ID
  - **Location:** Apple Developer Portal > Membership
  - **Format:** 10-character string (e.g., `ABCD123456`)

**Example with actual values:**

```swift
import Foundation

struct PrivateConstants {
    static let authKeyPath = "./Resources/AuthKey.p8"
    static let authKeyID = "ABC123DEFG"
    static let teamID = "ABCD123456"
}
```

**File Structure After Setup:**

```
DeviceCheckServer/
├── Resources/
│   └── AuthKey.p8                    # Your actual .p8 key file (NOT in git)
└── Sources/
    └── App/
        └── PrivateConstants.swift    # Your actual config (NOT in git)
```

**Security Notes:**

- ✅ `PrivateConstants.swift` is in `.gitignore` - your secrets won't be committed
- ✅ `AuthKey.p8` files are in `.gitignore` - your keys won't be committed
- ⚠️ Never commit your actual credentials to the repository

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

## Debugging with Proxyman

You can use [Proxyman](https://proxyman.com/) to inspect the HTTP requests your server makes to Apple's DeviceCheck API.

### Method 1: Automatic Setup (Recommended)

1. Open Proxyman
2. Go to **Setup** → **Automatic Setup**
3. Click **Open New Terminal**
4. In the new Terminal window, navigate to your project and run:
   ```bash
   cd DeviceCheckServer
   swift run
   ```
5. All HTTP/HTTPS traffic from this Terminal session will be captured by Proxyman

### Method 2: Programmatic Proxy Configuration

The server supports proxy configuration via environment variables:

```bash
cd DeviceCheckServer
USE_PROXY=true PROXY_HOST=localhost PROXY_PORT=9090 swift run
```

**Environment Variables:**
- `USE_PROXY=true` - Enable proxy (set to "true" to enable)
- `PROXY_HOST` - Proxy hostname (default: "localhost")
- `PROXY_PORT` - Proxy port (default: 9090)

**Proxyman Default Ports:**
- HTTP: `9090`
- HTTPS: `9091`

**Note:** For HTTPS traffic to Apple's API, you may need to trust Proxyman's certificate. Proxyman will guide you through this process.

## Implementation Status

**Device Identification:** ✅ **Fully Implemented**
- Real integration with Apple's DeviceCheck API
- JWT token generation with ES256 signing
- Query and update device bits functionality
- Comprehensive logging for debugging

**App Attest:** ⚠️ **Placeholder Implementation**
- Server includes endpoints for challenge generation, attestation, and assertion validation
- Currently returns mock responses
- To fully implement:
  1. Add proper CBOR parsing for App Attest attestation and assertion objects
  2. Implement cryptographic verification of App Attest signatures
  3. Store public keys for assertion validation

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

## Attribution

- App icon: [Mobile Phone Icon](https://www.flaticon.com/free-icon/check_14622071?term=mobile+phone&page=1&position=31&origin=search&related_id=14622071) from [Flaticon](https://www.flaticon.com/)

## License

See LICENSE.txt for details.

## Notes

- DeviceCheck is only available on physical iOS devices (iOS 11.0+)
- App Attest requires iOS 14.0 or later
- The two-bit storage is device-specific and persists across app installations
- Proper implementation requires server-side verification with Apple's servers

