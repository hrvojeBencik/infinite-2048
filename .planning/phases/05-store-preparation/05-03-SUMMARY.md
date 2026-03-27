---
phase: 05-store-preparation
plan: "03"
subsystem: store-metadata
tags: [aso, store-listing, metadata, version-bump]
dependency_graph:
  requires: [05-01, 05-02]
  provides: [STORE_LISTING.md, version-bump]
  affects: [pubspec.yaml]
tech_stack:
  added: []
  patterns: [ASO keyword strategy, store metadata copywriting]
key_files:
  created:
    - .planning/phases/05-store-preparation/STORE_LISTING.md
  modified:
    - pubspec.yaml
decisions:
  - "Subtitle trimmed to 'Puzzle with Levels & Zones' (26 chars) from spec's 31-char version to fit App Store 30-char limit"
  - "iOS keywords field uses 68 of 100 available chars — leaves room for future optimization without resubmission"
  - "Google Play full description opens with keyword-dense summary line per Play Store indexing best practice"
  - "Version bumped to 1.0.0+2 (build number only) — marketing version stays 1.0.0 for first public release"
metrics:
  duration: "2 minutes"
  completed: "2026-03-26"
  tasks_completed: 2
  files_created: 1
  files_modified: 1
---

# Phase 05 Plan 03: Store Listings and Version Bump Summary

**One-liner:** ASO-optimized App Store and Google Play metadata generated with 5-zone feature narrative, 68-char iOS keywords, and version bumped to 1.0.0+2 for release submission.

## What Was Built

### Task 1: ASO-Optimized Store Listings (STORE-04, STORE-05, STORE-09)

Created `.planning/phases/05-store-preparation/STORE_LISTING.md` containing complete metadata for both platforms:

**App Store (iOS):**
- Title: "2048: Merge Quest" (16 chars)
- Subtitle: "Puzzle with Levels & Zones" (26 chars — under 30 char limit)
- Keywords: `puzzle,merge,brain,number,tile,strategy,logic,casual,challenge,daily` (68 chars — under 100 char limit)
- Category: Games > Puzzle
- Full description: ~1,850 chars of casual, emoji-friendly copy organized as hook → zone features → level system → power-ups → achievements → endless mode → premium CTA
- Promotional text: 108-char seasonal text (updatable without resubmission)

**Google Play (Android):**
- Title: "2048: Merge Quest" (17 chars)
- Short description: "Classic 2048 puzzle with levels, zones, and daily challenges" (60 chars — under 80 char limit)
- Category: Game > Puzzle
- Full description: ~1,950 chars with keyword-dense opening two lines for Play Store indexing, same feature narrative, keyword footer for long-tail terms

**ASO keyword strategy:** Primary (2048, puzzle, merge, tiles), secondary (levels, zones, daily challenge, achievements), long-tail ("2048 with levels", "puzzle game offline", "brain training puzzle"). "2048" and "game" excluded from iOS keywords field (title/category already index them).

### Task 2: Version Bump (STORE-09)

Updated `pubspec.yaml` line 4: `1.0.0+1` → `1.0.0+2`. Marketing version stays 1.0.0 (first public release). Build number +2 avoids conflict with any prior test uploads.

## Commits

| Task | Commit | Description |
|------|--------|-------------|
| 1 | 3dbf426 | docs(05-03): generate ASO-optimized store listings |
| 2 | bf1fd8a | chore(05-03): bump app version to 1.0.0+2 |

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] App Store subtitle length**
- **Found during:** Task 1
- **Issue:** UI-SPEC copywriting contract lists subtitle as "Puzzle Game with Levels & Zones" (31 chars) which exceeds the App Store 30-char hard limit
- **Fix:** Trimmed to "Puzzle with Levels & Zones" (26 chars) — same meaning, retains all keywords, within limit
- **Files modified:** `.planning/phases/05-store-preparation/STORE_LISTING.md`
- **Commit:** 3dbf426

## Known Stubs

None — this plan produces static metadata files, not UI components. No stubs introduced.

## Self-Check: PASSED

- `.planning/phases/05-store-preparation/STORE_LISTING.md` — FOUND
- `pubspec.yaml` contains `version: 1.0.0+2` — FOUND
- Commit 3dbf426 — FOUND
- Commit bf1fd8a — FOUND
- `grep -c "2048: Merge Quest" STORE_LISTING.md` returns 9 (≥ 2 required) — PASSED
