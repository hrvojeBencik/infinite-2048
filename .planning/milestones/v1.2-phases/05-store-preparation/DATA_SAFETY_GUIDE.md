# Google Play Data Safety Form — Field-by-Field Guide

## Overview

This guide tells you exactly what to select in Google Play Console → App content → Data safety. Work through each section top-to-bottom. The app uses Google Mobile Ads (AdMob), Firebase Analytics, and optional Firebase Auth — these determine the declarations.

**Privacy Policy URL:** `https://hrvojebencik.github.io/infinite-2048/privacy-policy.html`

---

## Section 1: Data Collection and Security

### Does your app collect or share any of the required user data types?
**Answer: Yes**

### Is all of the user data collected by your app encrypted in transit?
**Answer: Yes** — all SDKs (AdMob, Firebase) use TLS for data transmission.

### Do you provide a way for users to request that their data is deleted?
**Answer: Yes (conditional)** — Firebase Auth supports account deletion, which deletes associated authentication data. If you do not implement sign-in at all, you may answer No.

---

## Section 2: Data Types to Declare

### 1. Device or other IDs

| Field | Answer |
|-------|--------|
| Collected? | Yes |
| Shared? | Yes |
| Shared with whom? | Google AdMob (advertising purposes) |
| Processing purpose | Advertising or marketing |
| Required or optional? | Required — cannot opt out (managed by AdMob SDK) |
| Encrypted in transit? | Yes |
| Can users request deletion? | No (managed by Google AdMob SDK) |

**Why:** Google Mobile Ads SDK collects the Android Advertising ID (GAID) for ad targeting and frequency capping.

**Reference:** https://developers.google.com/admob/android/privacy/play-data-disclosure

---

### 2. App interactions

| Field | Answer |
|-------|--------|
| Collected? | Yes |
| Shared? | Yes |
| Shared with whom? | Firebase Analytics |
| Processing purpose | Analytics |
| Required or optional? | Required — collection happens automatically |
| Encrypted in transit? | Yes |
| Can users request deletion? | No |

**Why:** Firebase Analytics tracks in-app events (level completions, gameplay actions, screen views) automatically once initialized.

**Reference:** https://firebase.google.com/docs/android/play-data-disclosure

---

### 3. App info and performance (Crash logs)

| Field | Answer |
|-------|--------|
| Collected? | Yes |
| Shared? | Yes |
| Shared with whom? | Firebase Crashlytics |
| Processing purpose | App functionality, Analytics |
| Required or optional? | Required — crash reports are automatic |
| Encrypted in transit? | Yes |
| Can users request deletion? | No |

**Why:** Firebase Crashlytics automatically collects crash reports, stack traces, and device state at crash time.

---

### 4. Personal info (Name, Email address) — CONDITIONAL

| Field | Answer |
|-------|--------|
| Collected? | Only if user signs in via Firebase Auth (Google/Apple Sign-In) |
| Shared? | No — stays in Firebase Auth |
| Processing purpose | Account management |
| Required or optional? | **Users can choose** — sign-in is optional in this app |
| Encrypted in transit? | Yes |
| Can users request deletion? | Yes — Firebase Auth supports account deletion |

**Why:** When a user signs in with Google or Apple, Firebase Auth receives their name and email address. Because sign-in is optional (app is playable without signing in), this data type is marked as user-optional.

**Action:** If you choose to remove sign-in functionality before launch, omit this section entirely.

---

## Section 3: Data Types to Answer "No" (Do Not Declare)

| Data Type | Answer | Reason |
|-----------|--------|--------|
| Financial info | **No** | No payment processing in-app (RevenueCat handles IAP natively via App Store/Play Store) |
| Health and fitness | **No** | Not applicable |
| Location | **No** | App does not use GPS or network location |
| Messages | **No** | No messaging features |
| Photos and videos | **No** | App does not access photo library (share card is generated in-memory, not saved to photos) |
| Audio | **No** | App plays audio files bundled in app assets; does not access device microphone or audio library |
| Files and docs | **No** | Not applicable |
| Calendar | **No** | Not applicable |
| Contacts | **No** | Not applicable |
| Web history | **No** | Not applicable |
| Browsing history | **No** | Not applicable |

---

## Section 4: Security Practices

| Question | Answer |
|----------|--------|
| Does your app use encryption when transferring data? | **Yes** — all SDK communication uses TLS |
| Does your app follow the Families Policy? | No (unless targeting children — this app does not) |
| Is your app independently security reviewed? | No (optional — skip unless you have a cert) |

---

## Section 5: Privacy Policy

**Field:** Privacy policy URL
**Value:** `https://hrvojebencik.github.io/infinite-2048/privacy-policy.html`

Verify the URL is accessible before submitting. The policy should cover:
- What data is collected (advertising ID, analytics events, crash logs)
- Who it is shared with (Google, Firebase)
- How users can request data deletion (Firebase Auth account deletion)

---

## Submission Checklist

- [ ] Data Safety section opened in Google Play Console → App content → Data safety
- [ ] "Device or other IDs" declared as collected + shared with AdMob
- [ ] "App interactions" declared as collected + shared with Firebase Analytics
- [ ] "App info and performance" declared as collected + shared with Firebase Crashlytics
- [ ] "Personal info" declared as conditional (if sign-in is enabled)
- [ ] All other data types answered "No"
- [ ] Privacy policy URL entered and verified accessible
- [ ] Form submitted and saved

---

## Reference Links

- AdMob disclosure guide: https://developers.google.com/admob/android/privacy/play-data-disclosure
- Firebase disclosure guide: https://firebase.google.com/docs/android/play-data-disclosure
- Google Play Data Safety help: https://support.google.com/googleplay/android-developer/answer/10787469
