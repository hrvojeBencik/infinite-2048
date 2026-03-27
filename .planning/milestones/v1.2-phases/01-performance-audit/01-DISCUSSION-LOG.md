# Phase 1: Performance Audit - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-26
**Phase:** 01-performance-audit
**Areas discussed:** Target devices, Dev tool design, Findings format, SoundService scope

---

## Target Devices

| Option | Description | Selected |
|--------|-------------|----------|
| Physical Android only | Specific Android device to profile on | |
| Physical iOS only | iPhone/iPad to profile on | |
| Both platforms | Both Android and iOS physical devices | ✓ |
| Emulator only | No physical devices | |

**User's choice:** Both platforms available

| Option | Description | Selected |
|--------|-------------|----------|
| I'll share specs | Tell exactly which devices | |
| You decide baseline | Define 'mid-range' criteria, user matches a device | ✓ |

**User's choice:** Claude defines mid-range baseline criteria

| Option | Description | Selected |
|--------|-------------|----------|
| Android primary (Recommended) | Android is harder for Flutter perf — profile there first, spot-check iOS | ✓ |
| Both equally | Full profiling on both platforms | |
| iOS primary | Profile iOS first | |

**User's choice:** Android primary

---

## Dev Tool Design

| Option | Description | Selected |
|--------|-------------|----------|
| Toggle in dev page (Recommended) | Switch in existing dev options page, enables PerformanceOverlay | ✓ |
| Always on in debug | Always visible in debug builds | |
| Floating button | Floating dev button on game screen | |

**User's choice:** Toggle in dev page

| Option | Description | Selected |
|--------|-------------|----------|
| Automated frame budget test (Recommended) | Dev page button, scripted sequence, reports pass/fail with frame stats | ✓ |
| Manual checklist | Documented checklist to manually test | |
| Integration test | flutter_test integration test for CI | |

**User's choice:** Automated frame budget test

---

## Findings Format

| Option | Description | Selected |
|--------|-------------|----------|
| Markdown report in .planning (Recommended) | Structured PERF-BASELINE.md with baseline numbers, jank sources, audits, Phase 2 recommendations | ✓ |
| Inline code comments | TODO/PERF comments in source files | |
| Both | Markdown summary + inline TODOs | |

**User's choice:** Markdown report in .planning

---

## SoundService Scope

| Option | Description | Selected |
|--------|-------------|----------|
| Mark resolved, note in report (Recommended) | Document haptic-only status, mark PERF-05 N/A, re-audit if audio added later | ✓ |
| Audit the haptic calls | Check if HapticFeedback calls cause frame drops during rapid merges | |
| Pre-audit for future audio | Design AudioPlayer pooling architecture now | |

**User's choice:** Mark resolved, note in report

---

## Claude's Discretion

- Mid-range device criteria definition
- Scripted gameplay sequence design for regression test
- Jank severity ranking methodology
- PERF-BASELINE.md report structure

## Deferred Ideas

None — discussion stayed within phase scope.
