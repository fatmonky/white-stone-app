# White Stone - Development Log

## Overview

White Stone is a native iOS app (SwiftUI + SwiftData) inspired by the ancient Indian practice of marking thoughts and actions with white stones (good) or black stones (unwholesome). It's a daily tracker where users log stones throughout the day and review their patterns over time.

## Tech Stack

- **UI**: SwiftUI (iOS 17+)
- **Storage**: SwiftData (local, single `Stone` model)
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
    ContentView.swift               # TabView (Today, Calendar, Trends)
    Today/
      TodayView.swift               # Main dashboard: tappable stone icons, ratio bar
      RatioBar.swift                # White/black proportional bar
    AddStone/
      AddStoneSheet.swift           # Modal: stone type + multi-line note
    Calendar/
      CalendarView.swift            # Month grid, colour-coded days, month nav
      DayCell.swift                 # Single day cell with ratio colour
    StoneDetail/
      StoneDetailView.swift         # Editable stone detail (type, time, note)
    Trends/
      TrendsView.swift              # Overview stats, daily stacked bar chart
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
- Ratio bar with "This is your day ratio so far" label, positioned under date
- Large tappable white stone (160pt) above black stone, stacked vertically
- Tap a stone to open Add Stone sheet
- Haptic feedback on stone tap
- Brown accent colour for active tab

### Add Stone Sheet
- Modal with stone type indicator and icon
- Multi-line text editor for notes (with placeholder)
- Save/Cancel toolbar buttons

### Calendar
- Month grid (LazyVGrid, 7 columns) with weekday headers
- Days colour-coded by white/black ratio (white-to-black spectrum)
- Month navigation (chevron left/right)
- Tap a day to view inline stones timeline for that date

### Stone Detail
- Editable view: stone icon/type plus editable timestamp and note

### Trends
- Overview section: Total White (with icon), Total Black (with icon), Streak (brown)
- Daily stacked bar chart (past 14 days) — white bars stacked on black bars
- Chart legend with white/black labels

## Recent Updates (28 February 2026)

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
