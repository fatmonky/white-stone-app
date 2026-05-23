# White Stone - Development Log

## Overview

White Stone is a native iOS app (SwiftUI + SwiftData) inspired by the ancient Indian practice of marking thoughts and actions with white stones (good) or black stones (unwholesome). It's a daily tracker where users log stones throughout the day and review their patterns over time.

## Tech Stack

- **UI**: SwiftUI (iOS 17+)
- **Storage**: SwiftData (local `Stone` and `Reflection` models)
- **Charts**: Swift Charts (first-party)
- **Project generation**: XcodeGen (`project.yml` → `.xcodeproj`)
- **No third-party dependencies**

## Project Structure

```
WhiteStone/
  App/WhiteStoneApp.swift          # Entry point, SwiftData container
  Models/Stone.swift                # @Model: type, timestamp, note
  Views/
    SplashView.swift                # Launch screen: "White Stone, tracker of mental action"
    ContentView.swift               # TabView + first-run onboarding flow
    Today/
      TodayView.swift               # Main dashboard: flippable stone, onboarding coach, ratio bar
      RatioBar.swift                # White/black proportional bar
    AddStone/
      AddStoneSheet.swift           # Modal: stone type, time, and note
    Review/
      ReviewView.swift              # Calendar, stats, 14-day bars, all-time bars
      Calendar/
        DayCell.swift               # Single day cell with ratio colour
      Patterns/
        PatternsView.swift          # Local-only pattern observations
    Reflection/
      ReflectionView.swift          # Daily and by-question reflection root
    StoneDetail/
      StoneDetailView.swift         # Editable stone detail (type, time, note)
    Components/
      StoneIcon.swift               # Reusable white/black circle
      EmptyStateView.swift          # Empty state placeholder
  Utilities/
    DateHelpers.swift               # Calendar math, date formatting
    ColorHelpers.swift              # Ratio-to-colour mapping (white/black spectrum)
  Assets.xcassets/                  # Accent colour (brown), app icon placeholder
  Preview Content/
project.yml                         # XcodeGen config
.gitignore                          # Ignores .xcodeproj, build output, DerivedData
```

## Key Design Decisions

- **Single `Stone` model** with timestamp-based day/month range fetches for filtering
- **No ViewModel layer** for MVP — `@Query` + `@State` handles all reactivity
- **XcodeGen** generates `.xcodeproj` from a 30-line YAML file (`.xcodeproj` is gitignored)
- **White/black/brown colour palette** — zen-inspired, no green/red

## Building

```bash
# Install XcodeGen (one-time)
brew install xcodegen

# Generate Xcode project
xcodegen generate

# Build for simulator
xcodebuild -project WhiteStone.xcodeproj -scheme WhiteStone \
  -destination 'platform=iOS Simulator,name=iPhone 16,OS=latest' build

# Or open in Xcode
open WhiteStone.xcodeproj
```

## Features Implemented

### Today Screen
- Splash screen on launch ("White Stone, tracker of mental action") that fades to dashboard
- "White Stone" displayed in navigation bar
- Date left-aligned under title
- Welcome sheet for first-run users, with optional skip path
- Guided coach overlay on Today that teaches swipe-to-flip and hold-to-log
- Ratio bar with "Your ratio today of good thoughts to bad thoughts" label, positioned under date
- Large 3D flippable stone (240pt) used for white/black selection
- Hold a stone to open Add Stone sheet
- Haptic feedback on flip and long press
- Brown accent colour for active tab

### Add Stone Sheet
- Modal with stone type indicator and icon
- Time picker for backdated entries within the day
- Multi-line text editor for notes (with placeholder)
- Save/Cancel toolbar buttons

### Review
- Month grid (LazyVGrid, 7 columns) with weekday headers
- Monday-first weekday layout
- Days colour-coded by white/black ratio (white-to-black spectrum)
- Month navigation (chevron left/right)
- Tap a day to view inline stones timeline for that date
- Low-emphasis stats: total days tracked, this month's stones, and preserved streak
- Daily stacked bar chart (past 14 days) with swipeable windows
- Tap a chart day to reveal that day's stones inline
- All-time monthly stacked bar chart
- Local-only pattern observations in the Patterns section
- Post-first-entry onboarding points users here after their first save
- Reflection markers and selected-day reflection cards

### Reflections
- Daily AN 10.51 question rotation
- One saved reflection per date
- By-question review with expandable sections
- Editable reflection detail with previous/next navigation for the same question
- First-run onboarding now includes a Reflections tour after the Review tour

### Optional Stone Tags
- Root tags constrained by stone color
- Multi-root and custom descriptor support
- Strong/weak intensity tag
- Tag display in Review and Stone Detail

### Stone Detail
- Editable view: stone icon/type plus editable timestamp and note

## Recent Updates

### 23 May 2026

- Added `ONBOARDING_REFLECTIONS_PLAN.md` to capture the planned onboarding flow update and verification checklist.
- Extended first-run onboarding from `welcome -> todayCoach -> firstLog -> reviewTour -> completed` to `welcome -> todayCoach -> firstLog -> reviewTour -> reflectionsTour -> completed`.
- Added a Reflections tour overlay that introduces the daily question, saved responses, by-question review, and Review calendar reflection markers.
- Updated Review onboarding so its primary action continues to Reflections instead of ending the tour.
- Updated onboarding copy in the welcome and first-stone success sheets to mention both Review and Reflections.
- Preserved `.reflectionsTour` across relaunches and restored the Reflections tab when onboarding resumes at that step.
- Verified with `xcodebuild -project WhiteStone.xcodeproj -scheme WhiteStone -destination 'platform=iOS Simulator,name=iPhone 17' build`.
- Verified with `xcodebuild -project WhiteStone.xcodeproj -scheme WhiteStone -destination 'platform=iOS Simulator,name=iPhone 17' test`, passing 12 tests.
- Ran the app in the iOS Simulator, cleared prior simulator app data, and relaunched to show the fresh onboarding flow.
- Committed and pushed the change to `origin/main` as `14f8c74 Add reflections onboarding tour`.

### 5 May 2026

- Added Phase 4 local-only pattern observations in Review.
- Added a `WhiteStoneTests` target with focused unit tests for PatternEngine, reflection rotation, and stone tags.
- Updated docs to match the implemented Reflections and tagging features.

### 1 May 2026

- Collapsed Calendar and Trends into a single Review tab.
- Preserved the existing stone-logging streak inside Review without adding new streak mechanics.
- Added Review sections for 14-day bars, all-time monthly bars, and the Patterns empty state.
- Added the Reflections tab.

### 8 March 2026

- Added first-run onboarding state in `ContentView` using `@AppStorage`.
- Introduced a welcome sheet, Today coach overlay, and post-first-entry success sheet.
- Added feature nudges for Calendar and Trends after onboarding.
- Synced `Stone.dayKey` automatically when editing a stone's timestamp.

### 28 February 2026

- Day grouping now uses timestamp day-interval queries instead of relying on stored day keys in views.
- Chart tap selection in Trends now converts gesture x-coordinate to the chart plot area.
- Today, Calendar, and Trends use targeted SwiftData fetches to reduce repeated full-dataset filtering.
- Calendar selection now resets to a valid day when switching months.
- Removed unused `DayDetailView.swift` and regenerated project metadata.

## Running on Physical Device

1. Open `WhiteStone.xcodeproj` in Xcode
2. Xcode > Settings > Accounts > add your Apple ID
3. Select WhiteStone target > Signing & Capabilities > enable "Automatically manage signing" > select your Personal Team
4. Connect iPhone via USB, select it as build destination
5. Cmd+R to build and run
6. First time: on iPhone, go to Settings > General > VPN & Device Management > trust your developer profile
