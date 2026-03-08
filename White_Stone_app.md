# White Stone app

**List:** Inbox
**Last Activity:** 2026-03-08

## Description

Inspired by the ancient Indian practice of marking a thought or action with a white stone (good action) or black stone (bad action). White Stone is now a guided daily tracker where users log wholesome and unwholesome thoughts, review each day on a calendar, and inspect patterns in a lightweight trends view.

## Key Features

- First-run onboarding with a welcome sheet, guided Today coach, post-first-entry success sheet, and short Calendar/Trends tours
- Swipe the main stone left or right to switch between white and black, then hold to log it
- Daily white/black ratio and timeline of today's stones
- Calendar month grid showing each day's white/black balance
- Trends overview with total white stones, total black stones, streak, and a 14-day stacked chart

## Design Direction

Minimal and meditative UI. Think zen/stone garden aesthetic.

## Platform / Stack

Native iOS app (SwiftUI). Local-first with SwiftData storage.

## MVP (v1)

1. One flippable stone used to choose white vs black, then hold to open the Add Stone sheet
2. Today's tally displayed as counts, a ratio bar, and an inline list of today's logged stones
3. Calendar view showing past days coloured by ratio, with inline review of the selected day
4. Trends view showing totals, streak, and a 14-day stacked bar chart

## Breadboard Flows

### Places

| # | Place | Purpose |
|---|-------|---------|
| 1 | TODAY | Home screen — today's tally, flippable stone, onboarding coach |
| 2 | ADD STONE | Modal — log a white or black stone with time and optional note |
| 3 | CALENDAR | Month grid, colour-coded by ratio, selected-day review |
| 4 | STONE DETAIL | Single stone view — timestamp and note for a specific stone |
| 5 | TRENDS | Totals, streak, and 14-day chart |
| 6 | ABOUT | Background and guidance |

### Breadboard

```
ONBOARDING
─────────────────────────────
  Welcome sheet
    [Start Tour] ──→ TODAY coach
    [Skip]       ──→ TODAY

  TODAY coach
    [Next]       ──→ hold-to-log step
    [Try it now] ──→ TODAY
    [Not now]    ──→ onboarding complete

  First saved stone
    Success sheet
      [Continue to Calendar] ──→ CALENDAR tour
      [Finish Without Tour]  ──→ onboarding complete


TODAY
─────────────────────────────
  Stone tally (e.g. "3 ⚪  1 ⚫")
  Stone ratio bar
  Flippable stone
    [Swipe]      ──→ switch white/black
    [Hold]       ──→ ADD STONE
  Today's stone timeline
  [Calendar tab] ──→ CALENDAR
  [Trends tab]   ──→ TRENDS


ADD STONE
─────────────────────────────
  Stone type label (White / Black)
  Time picker
  Note field (optional)
  [Save]    ──→ TODAY (count updated)
  [Cancel]  ──→ TODAY


CALENDAR
─────────────────────────────
  Month grid coloured by day ratio
  Month nav (‹ ›)
  Selected-day stone list inline
  Tour card (first-run only)
    [Next: Trends] ──→ TRENDS tour
    [Skip Tour]    ──→ onboarding complete
  [Tap a stone]    ──→ STONE DETAIL
  [Today tab]      ──→ TODAY
  [Trends tab]     ──→ TRENDS


STONE DETAIL
─────────────────────────────
  Stone type (White / Black)
  Timestamp
  Note (if any)
  [Back]          ──→ DAY DETAIL


TRENDS
─────────────────────────────
  Total white / total black / streak
  14-day stacked chart
  Tap a day to reveal stones inline
  Tour card (first-run only)
    [Finish Tour] ──→ onboarding complete
    [Skip Tour]   ──→ onboarding complete
  [Today tab]     ──→ TODAY
  [Calendar tab]  ──→ CALENDAR
```

### Key Flows

1. **First-run path:** Welcome → Today coach → hold to log → success sheet → Calendar tour → Trends tour
2. **Core loop:** TODAY → [Hold stone] → ADD STONE → [Save] → TODAY
3. **Review past days:** TODAY → [Calendar tab] → CALENDAR → [Tap day] → inline stones
4. **View a stone:** TODAY/CALENDAR/TRENDS inline list → [Tap a stone] → STONE DETAIL
5. **Check trends:** TODAY → [Trends tab] → TRENDS

## User Flow (summary)

1. User opens app for the first time → sees a welcome sheet and guided Today onboarding
2. User swipes the stone to choose white or black, then holds it to open Add Stone
3. After the first save, user sees a short Calendar and Trends tour
4. User can then revisit Today, Calendar, Trends, and About via the tab bar

## Storage

SwiftData (local). Each logged stone stores its type, timestamp, note, and derived day key.
