# Infinite 2048 -- Manual Setup Guide

This document covers all manual configuration steps required before building and running the app.

> **The app will run in offline/guest mode without any of these configurations.** Firebase, ads, and subscriptions are all optional and fail gracefully if not configured.

---

## 1. Firebase Setup (Required for Auth & Cloud Sync)

### 1.1 Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" and follow the wizard
3. Enable Google Analytics if desired

### 1.2 Configure with FlutterFire CLI

```bash
# Install the FlutterFire CLI if you haven't
dart pub global activate flutterfire_cli

# Run the configuration wizard from the project root
flutterfire configure
```

This will:
- Register your iOS and Android apps with Firebase
- Generate `lib/firebase_options.dart` (overwrites the placeholder)
- Download native config files automatically

### 1.3 Enable Authentication Providers

1. In Firebase Console, go to **Authentication > Sign-in method**
2. Enable **Google** provider
   - Note the Web Client ID (needed for Android Google Sign-In)
3. Enable **Apple** provider (for iOS)
   - Follow the Apple configuration steps shown in the console

### 1.4 Enable Cloud Firestore

1. In Firebase Console, go to **Firestore Database**
2. Click "Create database"
3. Choose production mode or test mode (for development)
4. Select a location close to your users

### 1.5 Firestore Security Rules

Deploy these rules for the `users` collection:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId}/{document=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    match /challenges/{document=**} {
      allow read: if true;
      allow write: if false;
    }
    match /leaderboards/{document=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

---

## 2. Google Sign-In Setup

### Android

Google Sign-In on Android uses Firebase Auth's `signInWithProvider(GoogleAuthProvider())` which is configured automatically when you run `flutterfire configure`. No additional setup required beyond Firebase.

If you encounter issues, ensure your SHA-1 fingerprint is registered in Firebase:

```bash
cd android && ./gradlew signingReport
```

Copy the SHA-1 from the output and add it to your Firebase Android app settings.

### iOS

1. In Firebase Console, download `GoogleService-Info.plist`
2. Open `ios/Runner.xcworkspace` in Xcode
3. Add `GoogleService-Info.plist` to the Runner target
4. Add the reversed client ID as a URL scheme:
   - Open `GoogleService-Info.plist` and find `REVERSED_CLIENT_ID`
   - In Xcode, go to Runner target > Info > URL Types
   - Add a new URL Type with the reversed client ID value

---

## 3. Apple Sign-In Setup (iOS only)

1. In the [Apple Developer Portal](https://developer.apple.com/):
   - Enable "Sign In with Apple" capability for your App ID
2. In Xcode:
   - Open `ios/Runner.xcworkspace`
   - Go to Runner target > Signing & Capabilities
   - Click "+ Capability" and add "Sign In with Apple"

---

## 4. AdMob Setup

### 4.1 Create AdMob Account

1. Go to [AdMob](https://admob.google.com/)
2. Create an account and register your app (iOS + Android separately)
3. Note down your App IDs for both platforms

### 4.2 Replace Test IDs

The app currently uses Google's official test Ad Unit IDs and App IDs. Before publishing, replace them with your real IDs:

**In `lib/core/constants/app_constants.dart`:**
- Replace all `ca-app-pub-3940256099942544/...` ad unit IDs with your real ones

**In `android/app/src/main/AndroidManifest.xml`:**
- Replace `ca-app-pub-3940256099942544~3347511713` with your real Android App ID

**In `ios/Runner/Info.plist`:**
- Replace `ca-app-pub-3940256099942544~1458002511` with your real iOS App ID

> **Warning:** Never use test IDs in production, and never use production IDs during development. Using production IDs during development violates AdMob policies and can get your account banned.

### 4.3 Create Ad Units

In AdMob dashboard, create the following ad units for each platform:
- **Banner** (for home page, level select)
- **Interstitial** (shown between levels)
- **Rewarded** (watch ad for power-up)

Update the IDs in `app_constants.dart`.

---

## 5. RevenueCat Setup (Subscriptions)

### 5.1 Create RevenueCat Account

1. Go to [RevenueCat Dashboard](https://app.revenuecat.com/)
2. Create a new project
3. Add your iOS and Android apps

### 5.2 Configure App Store / Play Store

**iOS (App Store Connect):**
1. Create subscription products in App Store Connect
   - Monthly: e.g., `infinite2048_monthly`
   - Yearly: e.g., `infinite2048_yearly`
2. Create a subscription group
3. In RevenueCat, add your App Store Connect shared secret

**Android (Google Play Console):**
1. Create subscription products in Google Play Console
2. In RevenueCat, add your Google Play service account JSON

### 5.3 Configure RevenueCat

1. In RevenueCat dashboard, create an **Offering** with your packages
2. Create an **Entitlement** called `premium`
3. Link your subscription products to the entitlement
4. Note down your API keys for both platforms

### 5.4 Update API Keys

In `lib/core/constants/app_constants.dart`:
```dart
static const String revenueCatApiKeyIos = 'your_real_ios_key';
static const String revenueCatApiKeyAndroid = 'your_real_android_key';
```

---

## 6. App Store / Play Store Configuration

### iOS App Store

1. Set your Bundle ID in Xcode (Runner > General > Identity)
2. Configure your signing team and provisioning profiles
3. Set the correct version and build number

### Google Play Store

1. Update the `applicationId` in `android/app/build.gradle.kts`
2. Set up your signing keystore for release builds
3. Configure the version code and version name

---

## 7. Quick Start (Development)

To run the app immediately without any service configuration:

```bash
# Install dependencies
flutter pub get

# Run in debug mode (works without Firebase/AdMob/RevenueCat)
flutter run
```

The app will:
- Start in **guest mode** (no cloud sync)
- Skip ad loading (no AdMob configured)
- Show placeholder subscription offerings
- All game features work locally via Hive storage

---

## 8. Checklist Before Publishing

- [ ] Run `flutterfire configure` and verify `firebase_options.dart` has real values
- [ ] Enable Google and Apple auth providers in Firebase Console
- [ ] Set up Firestore with security rules (see Leaderboard section below)
- [ ] Replace all AdMob test IDs with production IDs
- [ ] Configure RevenueCat with real API keys and products
- [ ] Configure Apple Sign-In capability in Xcode
- [ ] Add SHA-1 fingerprint to Firebase for Android
- [ ] Set up app signing for both platforms
- [ ] Test in-app purchases in sandbox/test environments
- [ ] Add privacy policy and terms of service URLs in Settings page
- [ ] Replace app icon and splash screen assets
- [ ] Test on physical devices (both iOS and Android)

---

## 9. Leaderboard Setup (Firestore)

The leaderboard uses Cloud Firestore. You need to:

### 9.1 Enable Firestore

1. Go to [Firebase Console](https://console.firebase.google.com) > Your Project > Firestore Database
2. Click **Create database** (if not already created)
3. Choose a region close to your users

### 9.2 Deploy Security Rules

In the Firebase Console > Firestore > Rules, paste the following:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /leaderboard/{docId} {
      // Anyone can read leaderboard entries
      allow read: if true;

      // Only authenticated users can write their own entries
      allow create, update: if request.auth != null
        && request.resource.data.uid == request.auth.uid
        && docId.matches(request.auth.uid + '_.*');

      allow delete: if false;
    }
  }
}
```

### 9.3 Create Composite Index

For the leaderboard queries to work, create this composite index:

1. Go to Firebase Console > Firestore > Indexes
2. Click **Add Index** (or it may be auto-created on first query)
3. Collection: `leaderboard`
   - Field 1: `mode` (Ascending)
   - Field 2: `score` (Descending)
   - Query scope: Collection

Alternatively, run the app and check the debug console -- Firebase will print a direct link to create the required index when it's missing.
