# Session Notes — 14 February 2026

## Summary

Implemented 7 changes from user feedback PDF (`White Stone feedback 14 Feb 26.pdf`), plus a follow-up fix.

## Changes Implemented

### Today Screen

1. **Stone size increased 50%** — `StoneIcon` size changed from 160pt to 240pt in `TodayView.swift`.

2. **Haptic on stone flip** — Added `playFlipHaptic()` in `TodayView.swift`: two `.medium` intensity impacts 120ms apart, triggered on every swipe-to-flip gesture.

3. **Timeline gap fixed** — The vertical line connecting stone entries had gaps caused by `.padding(.vertical, 6)` on each row. Fixed by adding `.padding(.vertical, -6)` on the timeline `VStack` to extend lines through the padding area. Applied to `TodayView.swift`, `TrendsView.swift`, `DayDetailView.swift`, and `CalendarView.swift`. For Trends and Calendar, the `ForEach` was additionally wrapped in a `VStack(spacing: 0)` to prevent the parent VStack's spacing from creating extra gaps.

4. **About tab added** — New `AboutView.swift` created under `WhiteStone/Views/About/`. Contains the Upagupta story text with bold formatting for key phrases and the source citation styled in the app's brown accent colour. Added as a 4th tab in `ContentView.swift` with an `info.circle` icon. Back button was initially added but removed per follow-up feedback.

### Stone Log Entry Modal

5. **Time picker added** — `AddStoneSheet.swift` now includes a `DatePicker` with `.hourAndMinute` components. Defaults to the current time. The selected time is passed to the `Stone` initialiser on save.

### Trends Screen

6. **StonesView fade-in animation** — When a chart bar is tapped, the stones list now starts at opacity 0 and fades to full opacity after a 150ms delay using `withAnimation(.easeIn(duration: 0.3).delay(0.15))`. This prevents the drop-from-top animation from showing a partially visible list mid-movement.

### Calendar View

7. **Stones shown persistently below calendar** — `CalendarView.swift` was rewritten to show the selected day's stones inline below the calendar grid instead of navigating to `DayDetailView`. Includes stone counts, ratio bar, and full timeline. The selected day defaults to today and is highlighted with a brown accent border. Tapping a different day updates the inline list.

## Files Changed

| File | Change |
|------|--------|
| `WhiteStone/Views/Today/TodayView.swift` | Stone size 160→240, flip haptic, timeline gap fix |
| `WhiteStone/Views/AddStone/AddStoneSheet.swift` | Added time picker |
| `WhiteStone/Views/Trends/TrendsView.swift` | Fade-in animation, timeline gap fix |
| `WhiteStone/Views/Calendar/CalendarView.swift` | Inline stones list, timeline gap fix |
| `WhiteStone/Views/DayDetail/DayDetailView.swift` | Timeline gap fix |
| `WhiteStone/Views/ContentView.swift` | Added About tab (4th tab) |
| `WhiteStone/Views/About/AboutView.swift` | **New file** — About screen with Upagupta story |
| `feedback/White Stone feedback 14 Feb 26.pdf` | Feedback document for this session |

## Build & Run

- Project regenerated with `xcodegen generate` to include the new `AboutView.swift`.
- Built and tested on iPhone 16e Simulator (iOS 18).
