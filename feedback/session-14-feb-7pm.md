# Session Notes — 14 Feb 2026, 7pm feedback round

## Source
Feedback PDF: `feedback/White Stone feedback 14 Feb 7pm.pdf`

## Changes Implemented

### 1. 3D Textured Stone (StoneIcon.swift)
- Large stones (>=60pt) now render with layered effects: radial gradient for 3D curvature, specular highlight, inner shadow, angular texture overlay, and a crisp outer stroke
- Small stones (timeline dots, counts) remain flat circles for clarity
- Follow-up fix: removed blur from inner shadow, thinned outer stroke to 1pt with darker gradient for sharper edge definition

### 2. Ratio Bar Label (TodayView.swift)
- Changed text from "This is your day ratio so far" to "Your ratio today of good thoughts to bad thoughts"

### 3. Long-Press Pulsing Haptic & Animation (TodayView.swift)
- Replaced tap-to-log with long-press gesture (0.8s duration)
- While pressing: stone pulses at 8Hz scale animation (0.95–1.06) with matching haptic feedback via Timer
- On completion: stops pulsing, opens Add Stone modal
- Swipe-to-flip gesture preserved
- Hint text updated to "Swipe to flip · Hold to log"

### 4. Trends View Opacity Fix (TrendsView.swift)
- Stone list was appearing semi-transparent during layout transition, overlapping the chart
- Fixed by keeping opacity at 0 during the 0.4s layout settle period, then fading in over 0.15s

### 5. Calendar Monday-Start & Weekday Headers (CalendarView.swift, DateHelpers.swift)
- Weekday headers changed from system `veryShortWeekdaySymbols` (Sunday-start) to explicit `["M", "T", "W", "T", "F", "S", "S"]`
- `weekdayOfFirst()` offset changed from `weekday - 1` (Sunday=0) to `(weekday + 5) % 7` (Monday=0)
- Follow-up fix: `ForEach` was collapsing duplicate letters ("T", "S"); switched to index-based `id: \.offset`

### 6. AboutView.swift Added to Xcode Project
- File existed on disk in `WhiteStone/Views/About/` but was missing from `project.pbxproj`
- Added PBXFileReference, PBXBuildFile, About group, and Sources build phase entry

## Commits
- `b221f0f` — Implement 14 Feb 7pm feedback: 3D stone, long-press pulse, calendar Monday-start
- `b9065d1` — Fix stone edge sharpness and calendar weekday headers

## Pending
- Deploy to physical iPhone blocked: device runs iOS 26.2.1 but Xcode 16.2 only supports up to iOS 18. Requires Xcode 26 beta (macOS upgrade in progress).
