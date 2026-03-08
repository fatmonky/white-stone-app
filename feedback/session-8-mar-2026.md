# Session Notes — 8 March 2026

## Summary

Reviewed the repo history and current implementation, aligned the model and docs with the latest onboarding work already present in code, then fixed several onboarding regressions and visual issues discovered during simulator verification later the same day.

## Changes Implemented

### 1. Stone model consistency

- `Stone.timestamp` now updates `dayKey` automatically whenever the timestamp changes.
- This keeps stored model data consistent when a user edits an existing stone in `StoneDetailView.swift`.

### 2. Repository docs refreshed

- `README.md` now documents the first-run onboarding flow and the current Add Stone / Today interactions.
- `DEVELOPMENT.md` now reflects the current interaction model: welcome sheet, Today coach, long-press logging, Monday-first calendar, and chart day selection in Trends.

### 3. Onboarding flow fixes

- `AddStoneSheet.swift` now dismisses before firing the post-save onboarding callback, avoiding a broken sheet-to-sheet handoff.
- `ContentView.swift` now preserves `.firstLog`, `.calendarTour`, and `.trendsTour` states after the first stone is saved instead of prematurely completing onboarding.
- The success sheet, Calendar tour, and Trends tour now progress in sequence as intended for first-run users.

### 4. Onboarding contrast improvements

- The Today coach card, Calendar tour card, and Trends tour card now use near-white backgrounds with a soft shadow instead of translucent material.
- This raises text contrast against the dimmed app background and keeps the onboarding visuals consistent across all guided overlays.

## Why this session

- The February markdown notes accurately described the earlier feedback rounds, but the repo had since gained onboarding in code that was not recorded in the main docs.
- `Stone.dayKey` was still stored on the model even though the main screens now fetch by date intervals. Without this fix, editing a timestamp could leave stale derived data behind.

## Files Changed

| File | Change |
|------|--------|
| `WhiteStone/Models/Stone.swift` | Keep `dayKey` synced when `timestamp` changes |
| `README.md` | Document onboarding and current recent changes |
| `DEVELOPMENT.md` | Refresh implementation notes to match current app behavior |
| `WhiteStone/Views/AddStone/AddStoneSheet.swift` | Dismiss save sheet before post-save onboarding callback |
| `WhiteStone/Views/ContentView.swift` | Preserve onboarding state across first-stone save and tour transitions |
| `WhiteStone/Views/Today/TodayView.swift` | Increase Today coach card contrast |
| `WhiteStone/Views/Calendar/CalendarView.swift` | Increase Calendar tour card contrast |
| `WhiteStone/Views/Trends/TrendsView.swift` | Increase Trends tour card contrast |
| `White_Stone_app.md` | Refresh product brief to match the current shipped flow |
| `feedback/session-8-mar-2026.md` | New session summary |
