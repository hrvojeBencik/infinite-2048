---
phase: 05-store-preparation
plan: "02"
subsystem: subscription
tags: [revenuecat, paywall, iap, bloc, apple-guideline-3.1.2]
dependency_graph:
  requires: [05-01]
  provides: [subscription-feature, paywall-screen, premium-status]
  affects: [lib/app/app.dart, lib/app/di.dart, lib/app/router.dart]
tech_stack:
  added: [purchases_flutter 9.15.1]
  patterns: [BLoC sealed classes, GetIt lazy singleton, RevenueCat SDK wrapper]
key_files:
  created:
    - lib/features/subscription/data/services/subscription_service.dart
    - lib/features/subscription/presentation/bloc/subscription_event.dart
    - lib/features/subscription/presentation/bloc/subscription_state.dart
    - lib/features/subscription/presentation/bloc/subscription_bloc.dart
    - lib/features/subscription/presentation/pages/paywall_page.dart
  modified:
    - pubspec.yaml
    - lib/core/constants/app_constants.dart
    - lib/app/di.dart
    - lib/app/app.dart
    - lib/app/router.dart
decisions:
  - "Used PurchaseParams.package() named constructor (purchases_flutter 9.x) instead of deprecated purchasePackage() returning CustomerInfo"
  - "Used introductoryPrice (purchases_flutter 9.x) instead of introductoryDiscount — free trial detected by price == 0"
  - "RevenueCat API keys stored as placeholder constants — safe to commit, operator must replace before submission"
metrics:
  duration: 8
  completed_date: "2026-03-27T07:30:06Z"
  tasks_completed: 2
  files_changed: 10
---

# Phase 5 Plan 2: RevenueCat Paywall Integration Summary

**One-liner:** Apple Guideline 3.1.2 compliant paywall with SubscriptionService, SubscriptionBloc (sealed classes), and global premium status via MultiBlocProvider.

## What Was Built

Full subscription feature following the project's clean architecture + BLoC pattern:

- **SubscriptionService** — RevenueCat SDK wrapper with explicit `initialize()`, `getOfferings()`, `purchasePackage()`, `restorePurchases()`, and `isPremium()` methods. Uses `PurchaseParams.package()` constructor for the purchases_flutter 9.x API.
- **SubscriptionEvent / SubscriptionState** — Sealed classes (per CLAUDE.md conventions) for events (`SubscriptionCheckRequested`, `SubscriptionLoadOfferings`, `SubscriptionPurchaseRequested`, `SubscriptionRestoreRequested`) and states (`SubscriptionInitial`, `SubscriptionLoading`, `SubscriptionLoaded`, `SubscriptionPurchasing`, `SubscriptionError`).
- **SubscriptionBloc** — Manages SDK initialization (called in `_onCheckRequested` and `_onLoadOfferings`), purchase flow, restore flow, and premium status tracking.
- **PaywallPage** — Apple Guideline 3.1.2 compliant full-screen paywall with: annual price at 24sp bold (most prominent), trial terms, cancel instructions, ToS/Privacy links with 44dp touch targets, Restore Purchase button, analytics events wired.
- **DI wiring** — SubscriptionService and SubscriptionBloc registered as lazy singletons in `di.dart`.
- **Global BlocProvider** — SubscriptionBloc provided at app root in MultiBlocProvider, initialized with `SubscriptionCheckRequested`.
- **Route** — `/paywall` route registered in go_router accepting optional `source` String via `state.extra`.

## Compliance Checklist (Apple Guideline 3.1.2)

- Annual price displayed as largest text element (24sp bold, white) — PASS
- Trial terms visible without scrolling — PASS
- Cancel instructions visible without scrolling ("Cancel anytime in your App Store settings") — PASS
- Terms of Service link tappable, opens via url_launcher — PASS
- Privacy Policy link tappable, opens via url_launcher — PASS
- Restore Purchase button available — PASS

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] Fixed purchases_flutter 9.x API incompatibility in SubscriptionService**
- **Found during:** Task 1 verification (`flutter analyze`)
- **Issue:** Plan used `purchasePackage(package)` returning `CustomerInfo?` — this is deprecated in purchases_flutter 9.x which returns `PurchaseResult` instead
- **Fix:** Changed to `Purchases.purchase(PurchaseParams.package(package))` returning `Future<void>`; updated method signatures accordingly
- **Files modified:** `lib/features/subscription/data/services/subscription_service.dart`
- **Commit:** 70c5375

**2. [Rule 1 - Bug] Fixed introductoryDiscount → introductoryPrice API mismatch**
- **Found during:** Task 2 verification (`flutter analyze`)
- **Issue:** Plan referenced `introductoryDiscount` field which doesn't exist in purchases_flutter 9.x; correct field is `introductoryPrice` of type `IntroductoryPrice`, with free trial detected by `price == 0`
- **Fix:** Changed all `introductoryDiscount` references to `introductoryPrice`, used `price == 0` for free trial detection
- **Files modified:** `lib/features/subscription/presentation/pages/paywall_page.dart`
- **Commit:** f0424dd

## Known Stubs

- `AppConstants.revenueCatAppleApiKey = 'appl_PLACEHOLDER_REPLACE_ME'` — Operator must replace with actual RevenueCat iOS public API key before App Store submission
- `AppConstants.revenueCatGoogleApiKey = 'goog_PLACEHOLDER_REPLACE_ME'` — Operator must replace with actual RevenueCat Android public API key before Play Store submission

These stubs are intentional and documented. The RevenueCat dashboard setup (project, entitlement, offering, subscription products) is a human action required outside this plan's scope.

## Commits

| Task | Commit | Description |
|------|--------|-------------|
| Task 1 | 70c5375 | feat(05-02): add SubscriptionService, SubscriptionBloc, and DI wiring |
| Task 2 | f0424dd | feat(05-02): build Apple 3.1.2 compliant PaywallPage and register /paywall route |

## Self-Check: PASSED
