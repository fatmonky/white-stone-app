# White Stone

White Stone is a mental tracking app that helps spiritual practitioners track the goodness of their thoughts and actions throughout a day.

## Inspiration

This app is inspired by Upagupta, the spiritual teacher of the ancient Indian Emperor Ashoka.

> "Upagupta … was a native of the Madura country. His instructor … told him to keep black and white pebbles. When he had a bad thought he was to throw down into a basket a black pebble; when he had a good thought he was to throw down a white pebble. Upagupta did as he was told. At first bad thoughts abounded, and black pebbles were very numerous.
> Then the white and black were about equal.
> On the seventh day there were only white pebbles.
> (His instructor) then undertook to expound to him the four truths."
>
> — *Chinese Buddhism*, Joseph Edkins, 1893, p.68

**What is a good thought?** Thoughts of letting go, kindness and gentleness.

**What is a bad thought?** Thoughts of sensual desire, ill will and ruthlessness.

But you are free to decide for yourself what are good thoughts or bad thoughts that you will be tracking with White Stone.

## Features

- **Today view** — A 3D interactive stone you swipe left/right to flip between white and black, and hold to log. See your daily tally and white/black ratio at a glance.
- **Calendar** — Month grid with days colour-coded by your white/black stone ratio. Tap any day to see its full timeline.
- **Trends** — Overview stats (total white, total black, streak) and a 14-day stacked bar chart.
- **About** — The story behind the app.

## Tech Stack

- **Platform:** Native iOS (iOS 17+)
- **UI:** SwiftUI
- **Storage:** SwiftData (local-first, no server)
- **Charts:** Swift Charts
- **Project generation:** XcodeGen (`project.yml` → `.xcodeproj`)
- **No third-party dependencies**

## Project Structure

```
WhiteStone/
  App/WhiteStoneApp.swift            # Entry point, SwiftData container
  Models/Stone.swift                  # @Model: type, timestamp, note, dayKey
  Views/
    SplashView.swift                  # Launch screen
    ContentView.swift                 # TabView (Today, Calendar, Trends, About)
    Today/TodayView.swift             # Main dashboard: flippable stone, ratio bar
    Today/RatioBar.swift              # White/black proportional bar
    AddStone/AddStoneSheet.swift      # Modal: stone type + note
    Calendar/CalendarView.swift       # Month grid, colour-coded days
    Calendar/DayCell.swift            # Single day cell with ratio colour
    DayDetail/DayDetailView.swift     # Timeline of stones for a day
    StoneDetail/StoneDetailView.swift # Read-only stone detail
    Trends/TrendsView.swift           # Stats and daily stacked bar chart
    About/AboutView.swift             # App story and guidance
    Components/StoneIcon.swift        # Reusable 3D stone rendering
    Components/EmptyStateView.swift   # Empty state placeholder
  Utilities/
    DateHelpers.swift                 # Calendar math, date formatting
    ColorHelpers.swift                # Ratio-to-colour mapping
project.yml                           # XcodeGen config
```

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

## Running on a Physical Device

1. Open `WhiteStone.xcodeproj` in Xcode
2. Xcode > Settings > Accounts > add your Apple ID
3. Select WhiteStone target > Signing & Capabilities > enable "Automatically manage signing" > select your Personal Team
4. Connect iPhone via USB, select it as build destination
5. Cmd+R to build and run
6. First time: on iPhone, go to Settings > General > VPN & Device Management > trust your developer profile
