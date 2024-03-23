
---

# Codono Mobile App Documentation

Welcome to the Codono Mobile App documentation. This guide is designed to help developers set up, compile, and make necessary changes to the app, which is built using Ionic 6.

## Table of Contents

- [Prerequisites](#prerequisites)
- [Setting Up the Development Environment](#setting-up-the-development-environment)
- [Compilation Instructions](#compilation-instructions)
  - [Android](#android)
  - [iOS](#ios)
- [Making Changes](#making-changes)
- [Troubleshooting](#troubleshooting)
- [Additional Resources](#additional-resources)

## Prerequisites

Before you begin, ensure you have the following installed:

- Node.js
- npm
- Ionic CLI
- Cordova
- Android Studio (for Android development)
- Xcode (for iOS development)

## Setting Up the Development Environment

1. Clone the project repository to your local machine.
2. Navigate to the project directory and run `npm install` to install the required dependencies.

## Compilation Instructions

### Android

To compile the app for Android, execute the following commands in sequence:

```shell
ionic capacitor add android
ionic capacitor copy
cordova-res android --skip-config --copy
ionic capacitor build android
```

### iOS

To compile the app for iOS, follow these steps:

```shell
ionic capacitor add ios
ionic capacitor copy
cordova-res ios --skip-config --copy
ionic capacitor build ios
```

After the build process, add the following entry to your `Info.plist` to handle camera permissions for QR code scanning:

```xml
<key>NSCameraUsageDescription</key>
<string>$(PRODUCT_NAME) uses Camera permission for QR code scanning</string>
```

## Making Changes

To modify the base currencies used in the app, change the following lines:

- In `src\app\pages\home\home.page.ts`, around line 141:
  ```typescript
  this.decoded.base = ['USDT', 'BNB', 'BUSD', 'TRY'];
  ```

- In `src\app\pages\market\market.page.ts`, around line 71:
  ```typescript
  this.decoded.base = ['USDT', 'BNB', 'BUSD', 'TRY'];
  ```

To update the API URL, make the following changes:

- In `src\app\app.component.ts`, replace:
  ```typescript
  Exchangeurl = 'https://yourexchange.com/';
  ```
- In `src\app\auth.service.ts`, modify:
  ```typescript
  let apiUrl = 'https://yourexchange.com/Api/';
  ```

## Troubleshooting

### Issue 1: Version Code Conflict

If you encounter a version code conflict in Android, navigate to `app\build.gradle` in Android Studio and increment the `versionCode`:

```gradle
versionCode 3 // Increment this by 1 from the current value
```

### Issue 2: Target API Level

To address the requirement of targeting at least API level 31, modify `variables.gradle`:

```gradle
targetSdkVersion = 31
```

Then, ensure your `AndroidManifest.xml` includes `android:exported="true"` for the main activity:

```xml
<activity android:exported="true">
```

## Additional Resources

- [Ionic Documentation](https://ionicframework.com/docs)
- [Android Developer Guide](https://developer.android.com/guide)
- [iOS Developer Guide](https://developer.apple.com/documentation)

---
