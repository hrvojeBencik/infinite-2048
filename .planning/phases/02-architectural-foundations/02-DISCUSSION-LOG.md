# Phase 2: Architectural Foundations - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-03-26
**Phase:** 02-architectural-foundations
**Areas discussed:** TileThemes refactor strategy, RepaintBoundary placement, BLoC rebuild guards, HapticService extraction

---

## TileThemes Refactor Strategy

| Option | Description | Selected |
|--------|-------------|----------|
| New ProgressionBloc (Recommended) | Dedicated bloc for player profile including tile theme | ✓ |
| Extend GameBloc | Add activeTheme to GameState | |
| Simple ValueNotifier | Lightweight ValueNotifier registered in GetIt | |

**User's choice:** New ProgressionBloc

| Option | Description | Selected |
|--------|-------------|----------|
| Theme only for now (Recommended) | Minimal scope — only tile theme in ProgressionBloc | |
| Full profile migration | Move player profile, XP, streaks, and tile theme all into ProgressionBloc | ✓ |

**User's choice:** Full profile migration

---

## RepaintBoundary Placement

| Option | Description | Selected |
|--------|-------------|----------|
| Three zones (Recommended) | Header/controls, score display, game board | ✓ |
| Per-widget | Wrap each major widget individually | |
| You decide | Claude determines granularity | |

**User's choice:** Three zones

---

## BLoC Rebuild Guards

| Option | Description | Selected |
|--------|-------------|----------|
| Split into targeted BlocBuilders (Recommended) | Multiple BlocBuilder widgets with buildWhen | ✓ |
| Keep single BlocConsumer + buildWhen | Add buildWhen to existing structure | |
| Selector pattern | Use BlocSelector for specific fields | |

**User's choice:** Split into targeted BlocBuilders

| Option | Description | Selected |
|--------|-------------|----------|
| GamePage only (Recommended) | Focus on highest-impact page | ✓ |
| All BLoC consumers | Audit every page | |

**User's choice:** GamePage only

---

## HapticService Extraction

| Option | Description | Selected |
|--------|-------------|----------|
| Own file + register in GetIt (Recommended) | Move to haptic_service.dart, register in di.dart, use sl<HapticService>() | ✓ |
| Own file, keep singleton | Move to own file but keep HapticService.instance | |
| Skip extraction | Leave in sound_service.dart | |

**User's choice:** Own file + register in GetIt

---

## Claude's Discretion

- ProgressionBloc state shape and event design
- Exact buildWhen conditions for each BlocBuilder
- Whether to keep TileThemes as utility class or fold into ProgressionBloc
- Implementation order

## Deferred Ideas

None — discussion stayed within phase scope.
