# White Stone app

**List:** Inbox
**Last Activity:** 2026-02-01

## Description

Inspired by the ancient Indian practice of marking a thought or action with a white stone (good action) or black stone (bad action). A simple daily tracker where you log positive actions and negative mental states, then see a visual "stone jar" over time.

Allows user to track good things done in a day, vs bad thoughts in the mind. There is a view that allows seeing the average stones across the days.

## Key Features

- Quick-tap logging of good deeds/thoughts and unwholesome thoughts throughout the day
- Daily white/black stone ratio
- Review view showing your "stone colour" for each day, recent bars, all-time bars, and streak
- Optional categories (generosity, patience, anger, worry, etc.)

## Design Direction

Minimal and meditative UI. Think zen/stone garden aesthetic.

## Platform / Stack

Native iOS app (SwiftUI). Local-first with SwiftData storage.

## MVP (v1)

1. Two buttons: "White Stone" (good deed/thought) and "Black Stone" (unwholesome thought) — tap to log
2. Today's tally displayed as a simple ratio and visual stone count
3. Review view showing past days coloured by ratio, recent bars, all-time bars, and the preserved streak

## Breadboard Flows

### Places

| # | Place | Purpose |
|---|-------|---------|
| 1 | TODAY | Home screen — today's stone tally and add buttons |
| 2 | ADD STONE | Modal — log a white or black stone with optional note |
| 3 | REVIEW | Month grid, recent bars, all-time bars, and streak |
| 4 | DAY DETAIL | Single day view — all stones and notes for that day |
| 5 | STONE DETAIL | Single stone view — timestamp and note for a specific stone |
| 6 | REFLECTION | Placeholder for daily reflection in Phase 2 |

### Breadboard

```
TODAY
─────────────────────────────
  Stone tally (e.g. "3 ⚪  1 ⚫")
  Stone ratio bar
  [+ White Stone] ──→ ADD STONE (type: white)
  [+ Black Stone] ──→ ADD STONE (type: black)
  [Review tab]    ──→ REVIEW
  [Reflection tab] ─→ REFLECTION


ADD STONE
─────────────────────────────
  Stone type label (White / Black)
  Note field (optional, one line)
  [Save]   ──→ TODAY (count updated)
  [Cancel]  ──→ TODAY


REVIEW
─────────────────────────────
  30-day colour-coded grid (green ← white, red ← black)
  Month nav (‹ ›)
  14-day bars
  All-time monthly bars
  Patterns placeholder
  [Tap a day]     ──→ DAY DETAIL
  [Today tab]     ──→ TODAY
  [Reflection tab] ─→ REFLECTION


DAY DETAIL
─────────────────────────────
  Date heading
  Stone count for that day
  List of stones with timestamps + notes
  [Tap a stone]   ──→ STONE DETAIL
  [Back]          ──→ REVIEW


STONE DETAIL
─────────────────────────────
  Stone type (White / Black)
  Timestamp
  Note (if any)
  [Back]          ──→ DAY DETAIL


REFLECTION (Phase 2 placeholder)
─────────────────────────────
  Daily reflection feature placeholder
  [Today tab]     ──→ TODAY
  [Review tab]    ──→ REVIEW
```

### Key Flows

1. **Core loop:** TODAY → [+ White Stone] → ADD STONE → [Save] → TODAY
2. **Review past days:** TODAY → [Review tab] → REVIEW → [Tap day] → DAY DETAIL → [Back] → REVIEW
3. **View a stone:** DAY DETAIL → [Tap a stone] → STONE DETAIL → [Back] → DAY DETAIL
4. **Check trends:** TODAY → [Review tab] → REVIEW → [14-day bars / All-time]

## User Flow (summary)

1. User opens app → sees today's stone count (e.g., "3 white, 1 black")
2. User taps "White Stone" → count increments, optional one-line note
3. User taps "Review" → sees past days as a colour-coded grid plus recent/all-time charts

## Storage

SwiftData (local) for v1. Each day's entry is a structured model with white/black counts and optional notes.
