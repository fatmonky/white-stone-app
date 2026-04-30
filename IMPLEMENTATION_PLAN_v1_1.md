# White Stone — v1.1 Implementation Plan

**Status:** Ready for implementation
**Date:** 30 April 2026
**Target repos:**
- `fatmonky/white-stone-app` (iOS, SwiftUI + SwiftData)
- `fatmonky/white-stone-app-android` (Android, Kotlin + Jetpack Compose + Room)

**Scope:** Refine the app from a passive logger into a contemplative practice tool. Strengthen the user's reflective feedback loop *without* introducing addictive gamification.

---

## 0. Guiding principles (non-negotiable)

Implementers must hold these as constraints throughout. If a UI choice tempts you toward "engagement" patterns familiar from habit/wellness apps, default to the opposite.

1. **Reinforce by noticing, not by scoring.** The app deepens the practice by slowing the user down — never by rewarding engagement.
2. **No new gamification primitives.** No new badges, achievements, levels, social or sharing features. The existing streak counter is preserved as-is — do not extend it, surface it more prominently, or add new streak-like mechanics (e.g. "longest streak", "streak recovery", milestone celebrations).
3. **Notifications are off by default.** At most one notification per day, and only if the user explicitly opts in.
4. **Friction at the moment of practice is welcome.** The hold-to-log gesture stays. New optional prompts (tagging, reflection) must be easily skippable but never rushed.
5. **Visual feedback stays naturalistic.** Stones, water, garden imagery. Avoid numeric "score" UIs that frame practice as performance.
6. **Local-first remains absolute.** No cloud, no analytics SDKs, no telemetry. SwiftData on iOS, Room on Android.
7. **Engagement decline is a feature, not a bug.** If a user gradually stops needing the app, the design has succeeded.

---

## 1. Summary of changes

| # | Change | Type | Phase |
|---|---|---|---|
| 1 | Collapse Calendar + Trends into a single **Review** tab | Refactor | 1 |
| 2 | Add new **Reflection** tab with daily AN 10.51 question | New feature | 2 |
| 3 | Optional tagging on stones (root + intensity) | Data model + UI | 3 |
| 4 | Pattern surfacing (informational, never competitive) | New feature | 4 |
| 5 | Opt-in end-of-day closure ritual | New feature | 5 |

New tab structure: **Today / Review / Reflection / About** (still 4 tabs).

---

## 2. Phase 1 — Review tab (consolidation)

### Goal

Replace the redundant Calendar and Trends tabs with a single Review tab. Calendar grid is the primary surface; charts and pattern observations are secondary. Strip out streak logic.

### Layout (top → bottom)

**a. Stat strip** — three lines, low emphasis, no emoji or color-coded "good/bad" signaling:
- Total days tracked
- Total stones logged this month (e.g., `12 white · 7 black`)
- Most-tagged root this week — *only render this line if tagging exists in the last 7 days; otherwise hide it*

**Streak handling:** the existing streak counter from the old Trends view is preserved and ported over into Review (it can sit in the stat strip area or as part of the 14-day bars view — whichever fits the layout cleanly). Do not redesign it, do not add new streak-related copy, do not introduce milestone moments. Carry it over as-is and leave it alone.

**b. Calendar (primary)**
- Carry over the current month-grid behavior and color mapping for day-ratio.
- Month nav (prev / next).
- Day cells get a small visual marker — e.g. a tiny dot in the corner — when that day has a reflection. Subtle, uniform color, not color-coded by stone ratio. (Implementation note: this becomes meaningful after Phase 2 lands; in Phase 1 the marker code can be stubbed and gated on whether a Reflection record exists.)
- Tap a day → DayDetail (extended in Phase 2 — see below).

**c. Secondary views** — accessible via a segmented control directly under the calendar, or by horizontal paging:
1. **14-day bars** — port over the existing Trends stacked bar chart.
2. **All-time** — month-over-month stacked bar (white vs. black per month). Compute from existing data.
3. **Patterns** — see Phase 4. Until Phase 4 ships, render an empty-state placeholder: "Patterns will appear here once you've logged a few weeks of stones."

### Files / structure changes

**iOS (`white-stone-app`)**
- Delete: `Views/Trends/TrendsView.swift` *after* moving its 14-day chart code and streak logic into the new Review structure — preserve existing behavior, do not lose the streak computation.
- Rename folder `Views/Calendar/` → `Views/Review/`.
- New: `Views/Review/ReviewView.swift` (tab root).
- Move `CalendarView.swift`, `DayCell.swift` under `Views/Review/Calendar/`.
- New: `Views/Review/Charts/BarChart14Day.swift` (port from old `TrendsView`).
- New: `Views/Review/Charts/AllTimeChart.swift`.
- Stub: `Views/Review/Patterns/PatternsView.swift` (empty state for now).
- Update `ContentView.swift` TabView: remove Trends tab; rename Calendar tab to Review.
- Tab icon suggestion: SF Symbol `calendar` (no badge); avoid anything that implies progress/score.

**Android (`white-stone-app-android`)**
- Mirror the same restructure. Likely under `app/src/main/java/.../ui/review/` with `Calendar.kt`, `BarChart14Day.kt`, `AllTimeChart.kt`, `Patterns.kt`.
- Update the bottom-nav / tab host to match the new 4-tab structure.
- Remove any streak code path.

### Acceptance

- App still has 4 tabs.
- Tapping the second tab opens Review.
- Calendar grid behavior is unchanged from prior Calendar tab.
- The 14-day bar chart is reachable from Review (one tap or one swipe away).
- The existing streak counter still works and is visible somewhere in Review with the same numeric value as before the refactor.
- All existing tests pass; add a smoke test asserting the tab title.

---

## 3. Phase 2 — Reflection tab (new)

### Goal

A quiet, daily self-examination space anchored in **AN 10.51 (*Sacitta Sutta* — One's Own Mind)**. One question per day, free-text journal response, no scoring, no analysis.

### The 10 daily reflection questions

Verbatim from AN 10.51 (Bhikkhu Sujato translation, SuttaCentral, released under CC0). Store these in a constant array; rotation is by `dayOfYear % 10` so the same date yields the same question across devices and reinstalls.

```
1.  Am I often covetous or not?
2.  Am I often malicious or not?
3.  Am I often overcome with dullness and drowsiness or not?
4.  Am I often restless or not?
5.  Am I often doubtful or not?
6.  Am I often irritable or not?
7.  Am I often corrupted in mind or not?
8.  Am I often disturbed in body or not?
9.  Am I often energetic or not?
10. Am I often immersed in samādhi or not?
```

A small attribution line appears once on first open of the tab, and again in About:

> *Daily questions from* Sacitta Sutta *(AN 10.51), translated by Bhikkhu Sujato, SuttaCentral (CC0).*

The Sujato translation is released under Creative Commons Zero, so verbatim use is permitted; preserve attribution as a matter of practice rather than legal requirement.

### Data model

New entity / model: **Reflection**
- `id` — UUID / primary key
- `date` — date the reflection is *for* (day-only, no time)
- `questionIndex` — Int (0–9), matches the question shown that day
- `responseText` — String, multiline, can be empty
- `createdAt` — timestamp

Constraint: one Reflection per day max. If the user opens the tab a second time the same day, they edit the existing entry rather than creating a new one.

### UX

The Reflection tab has exactly two subviews: **Today** (write today's reflection) and **By question** (re-read past answers grouped by question). Chronological day-by-day review of reflections lives in the Review tab's calendar — see "Cross-tab integration" below.

**Today subview (default):**
- Top: today's date and the question for today (large, calm typography).
- Just below the question, a quiet single line — *only if* the user has past entries on this same question: *"you've reflected on this question N times before."* Tappable; opens the By-question subview scrolled to today's question.
- Middle: free-text editor. Placeholder: *"Take your time. There's no need to write anything."* Empty saves create no Reflection record — only non-empty text is persisted.
- Bottom: a single "Save" affordance. After saving: gentle confirmation in-place; no toast, no animation.
- No "skip" button — the user simply doesn't write anything.

**By-question subview:**

Reachable via a small icon top-right of the Today view (a scroll / book icon). The 10 AN 10.51 questions listed as collapsible sections, in canonical order:

- Each section header shows the question and a small count: e.g. *"Am I often covetous or not? — 7 reflections."*
- Tapping the header expands the section to show every past reflection on that question, newest first, each with date and full text inline (no second tap required to read).
- If a question has zero reflections yet, render the header with *"no reflections yet on this question."* and no expansion content.
- This is the lens that quietly reveals how the practitioner's relationship to a single question has evolved across many cycles. It is the contemplative heart of the tab — give it visual care.

**Editing past reflections:** tap any past entry inline → opens `ReflectionDetailView`:
- Full date and question at the top.
- Full response text below, in a scrollable editable area.
- Edits save automatically on blur, or via an explicit "Save" button — match the platform convention.
- A small "← previous on this question" / "next on this question →" pair at the bottom, when applicable. Lets the user walk through their own answers to the same question across time without returning to the section list. **This is the single most powerful affordance in the feature** — it lets the practitioner read their own mind across weeks at a glance.
- No delete UI in v1.1. Clearing the text and saving deletes the record silently.

**Do not introduce a reflection-specific streak counter or "you've reflected N days in a row" copy.** The existing stone-logging streak (preserved from the prior Trends view) is the only streak the app has.

### Cross-tab integration: extending DayDetail in the Review tab

The chronological "what did I write that day" review lives in the Review tab, not the Reflection tab. This avoids redundancy and lets the calendar grid be the timeline.

**Calendar grid changes:**
- Day cells with a saved reflection get a small uniform marker (e.g. a tiny dot in the corner). Subtle, single colour, not tied to stone ratio.

**`DayDetailView` extension:**
- Single scrolling layout. Stones for that day at the top (existing behavior, unchanged). Reflection for that day below, if one exists, in a quiet card-like region with the date's question and the response.
- If the day has stones but no reflection, the reflection region is omitted entirely — no placeholder, no "add reflection" CTA. (DayDetail is for past days; reflections are written from the Reflection tab on the day itself.)
- Tap the reflection region → opens `ReflectionDetailView` for editing, same view as the By-question lens uses.
- If the day has a reflection but no stones (a quiet day), the stones region collapses gracefully — show only the reflection.

This means **Phase 2 also touches the Review tab's DayDetail**, which is fine because the Review tab is shipping in Phase 1 and DayDetail there is straightforward to extend.

### Files

**iOS**
- `Models/Reflection.swift` — `@Model` class.
- `Views/Reflection/ReflectionView.swift` — tab root (hosts Today and By-question via the top-right icon).
- `Views/Reflection/ReflectionTodayView.swift` — today's prompt + editor + "you've reflected on this N times" line.
- `Views/Reflection/ByQuestionView.swift` — collapsible sections per question.
- `Views/Reflection/ReflectionDetailView.swift` — single reflection, with previous/next-on-this-question navigation.
- `Utilities/ReflectionQuestions.swift` — constant array + `questionForDate(_ date: Date) -> (index: Int, text: String)` helper.
- Edit `Views/Review/Calendar/DayCell.swift` — add reflection-presence marker.
- Edit `Views/Review/Calendar/DayDetailView.swift` (or wherever DayDetail lives) — append reflection region below stones.
- Register Reflection in the SwiftData ModelContainer in `WhiteStoneApp.swift`.
- Add Reflection tab to TabView. Tab icon suggestion: `text.book.closed` or `mirror.side.left`.

**Android**
- `data/reflection/Reflection.kt` — Room `@Entity`.
- `data/reflection/ReflectionDao.kt` — include queries for: by-date (used by both DayDetail and Today), by-questionIndex (for By-question and prev/next navigation), all-with-counts-by-question.
- Add to `AppDatabase` (bump schema version, migration that adds the new table).
- `ui/reflection/ReflectionScreen.kt`, `ReflectionToday.kt`, `ByQuestion.kt`, `ReflectionDetail.kt`, `ReflectionQuestions.kt`.
- Edit Calendar / DayDetail composables in the Review tab to surface the reflection-presence marker and the reflection region in DayDetail.
- Add to bottom-nav.

### Acceptance

- Opening Reflection on day N shows the same question as `dayOfYear(N) % 10`.
- Writing text and saving creates exactly one Reflection record for that date; reopening the tab the same day shows the saved text.
- Saving an empty response on a previously-non-empty day deletes that reflection record.
- "You've reflected on this question N times before" line appears on the Today view if and only if N ≥ 1 for today's question, and tapping it opens the By-question subview expanded to today's question.
- By-question subview groups reflections under each of the 10 question headers with correct counts and inline content when expanded.
- Detail view's previous/next-on-this-question navigation correctly walks only across reflections sharing the same `questionIndex`, ordered chronologically.
- In the Review tab's calendar grid, days with a reflection display the marker; days without do not.
- DayDetail in the Review tab shows that day's reflection (if any) below the day's stones, and tapping it opens the editable detail view.
- No notification fires from this feature in this phase. (Notifications come in Phase 5.)

---

## 4. Phase 3 — Optional tagging on stones (root + intensity)

### Goal

Let the user optionally tag each stone along two independent axes:
1. **Root** — the underlying *vitakka* (thought-root) drawn from MN 19.
2. **Intensity** — how strong or weak the feeling tied to the stone was.

Both tags feed Phase 4 pattern surfacing later. Crucially: *both are always skippable, never required, never used to score.* They are independent — a user may tag root only, intensity only, both, or neither.

### Tag taxonomy (from MN 19, *Dvedhāvitakka Sutta*)

**Black stone (akusala-vitakka):**
- `sensual` — sensual desire (kāma-vitakka)
- `illWill` — ill will (byāpāda-vitakka)
- `harming` — harming / cruelty (vihiṃsā-vitakka)

**White stone (kusala-vitakka):**
- `renunciation` — letting go (nekkhamma-vitakka)
- `kindness` — loving-kindness (avyāpāda-vitakka)
- `harmlessness` — harmlessness (avihiṃsā-vitakka)

Store as a string enum. Allowed values are restricted to the appropriate set based on stone color.

### Tag taxonomy (intensity)

A simple two-value enum, applicable to white and black stones equally:
- `strong` — the thought or feeling was vivid, gripping, or persistent
- `weak` — the thought or feeling was faint, fleeting, or subtle

Nullable: a stone may have neither, root only, intensity only, or both. Do not introduce a "moderate" middle option in this release — keeping the choice binary preserves the contemplative quality of the noticing (the user must decide which way it tipped, which is itself a useful prompt for sati/sampajañña).

### Data model

Modify **Stone**:
- Add nullable `root: String?` (or enum-typed equivalent).
- Add nullable `intensity: String?` (values: `strong` | `weak`).
- Existing stones have both fields `null`. No backfill prompt — silent migration.

**iOS:** Add both properties to `Models/Stone.swift`. SwiftData handles lightweight migration; verify on a populated test database.

**Android:** Add both columns to the Room entity. Bump database version, write a migration that `ALTER TABLE` adds the two nullable columns.

### UX

In `AddStoneSheet` (and Android equivalent), after the existing fields (type, time, note), add **two optional rows**, each titled clearly:

**Row 1 — "Root (optional)"** — three chips, single-select, toggleable. Chips visible depend on stone color:
- White stone → renunciation, kindness, harmlessness
- Black stone → sensual desire, ill will, harming

**Row 2 — "Intensity (optional)"** — two chips, single-select, toggleable: `Strong` | `Weak`. Same chips regardless of stone color.

Visual: minimal text chips, no icons, no color emphasis, no required indicator. The two rows are visually equal in weight — neither feels primary. The Save button is enabled regardless of whether either tag is set.

In **StoneDetailView** and **DayDetailView**, if a stone has either tag, render them as small text labels next to the timestamp (e.g. `kindness · strong`). If a tag is missing, show nothing for it — never a placeholder like "untagged".

**Editing:** From StoneDetailView, the user can change or clear either tag independently.

### Acceptance

- Existing stones display unchanged.
- New stones can be saved with any combination of root and intensity tags, including neither.
- Tapping a chip a second time deselects it.
- The available root chips correctly switch when the user flips the stone color in the AddStone sheet.
- Intensity chips are identical across both stone colors.
- Root and intensity selections are independent — selecting one never changes the other.
- No part of the UI shows aggregate root or intensity counts in this phase — that's Phase 4.

---

## 5. Phase 4 — Pattern surfacing in Review tab

### Goal

In the Review tab's "Patterns" secondary view (stub from Phase 1), surface 1–3 quiet observations about the user's data. Purely informational. *No "good job", no "improvement", no comparisons to past self framed as performance.*

### Observation rules

Compute from local data only. Each observation either renders or is hidden (never show "no data" verbatim). Maximum 4 observations rendered at once, in this priority order:

1. **Time-of-day clustering** — if ≥10 stones in the last 14 days, compute the modal hour bucket (4-hour buckets: 6–10, 10–14, 14–18, 18–22, 22–6) for white and black stones separately. Render only if one bucket is clearly dominant (>50% of that color's stones).
   - Example: *"in the last two weeks, your black stones often appeared between 14:00 and 18:00."*

2. **Most-tagged root (this week)** — if ≥5 root-tagged stones in the last 7 days:
   - Example: *"most-tagged root this week: ill will."*

3. **Intensity tilt** — if ≥5 intensity-tagged stones in the last 14 days:
   - If strong tags outweigh weak by ≥2x: *"in the last two weeks, your stones have leaned strong."*
   - If weak outweighs strong by ≥2x: *"in the last two weeks, your stones have leaned weak."*
   - Otherwise: do not render this observation.
   - Pure observation, no judgment of which is "better." A practitioner may read meaning into either.

4. **Intensity × color cross-tag** — if ≥5 intensity-tagged stones of a single color in the last 14 days, and ≥70% of that color's tagged stones share an intensity:
   - Example: *"your strong stones recently have mostly been black."*
   - Example: *"your weak stones recently have mostly been white."*
   - Render at most one observation in this category.

5. **Logging cadence** — neutral observation about session frequency, e.g.:
   - *"you've been logging on most days this week."* — only render if 5+ of last 7 days have entries.
   - Or: *"it's been a few days since your last entry."* — only render if last entry is 3+ days ago. **Phrase as observation, not nag. No call-to-action.**

If more than 4 observations qualify, render the highest-priority 4.

### Phrasing rules

- Lower-case sentence style, no exclamation marks, no emoji.
- Never compare to a previous week or month (avoids the "you're slipping" framing).
- Never project future behavior.
- Never thank or congratulate the user.

### Files

- iOS: `Views/Review/Patterns/PatternsView.swift` + `Utilities/PatternEngine.swift` (pure function: `[Stone] -> [Observation]`).
- Android: equivalent.

### Acceptance

- With <10 stones logged, Patterns view shows a single empty-state line: *"Patterns will appear here once you've logged a few weeks of stones."*
- With sufficient data, observations appear and update on tab open.
- Unit test the pattern engine with synthetic stone data covering the edge cases for each observation rule.

---

## 6. Phase 5 — End-of-day closure ritual

### Goal

A single opt-in evening check-in. One notification per day at a user-chosen time. Tapping it opens a quiet evening view that creates closure for the day's practice and feeds the Reflection journal.

### Settings entry

Add a small **Settings** affordance, accessible from the About tab (gear icon top-right of About). Settings contains exactly:
- `Evening reflection` toggle — off by default.
- `Evening reflection time` — only visible when toggle is on. Time picker, default 21:00.

No other settings in this release.

### Notification

- Local notification only. iOS: `UNUserNotificationCenter`. Android: `AlarmManager` + `NotificationCompat`.
- Ask for permission only when the user toggles on, never preemptively.
- Body text: *"A quiet moment before the day ends."* — no emoji, no urgency.
- Tap → deep-links to the Evening view.

### Evening view

A modal sheet (iOS: `.sheet`; Android: bottom sheet or full-screen dialog). Layout:
- Top: today's date, then the day's stones rendered as a small visual — a flat row of stone shapes, white and black in chronological order. *No counts. No percentage. No ratio bar.*
- Middle: a single contemplative question. Use today's AN 10.51 question (same as Reflection tab) — this avoids two parallel question streams.
- Bottom: free-text editor. Pre-fills any existing Reflection entry for today; saving updates the same record.
- Single "Done" button. Dismisses without celebration.

### Behavior rules

- If the user opens the Evening view via the notification, the existing Reflection entry for today (if any) is loaded for editing.
- If the user already wrote a reflection earlier in the day, the notification still fires unless the toggle is off — they may want a second pass.
- If the user dismisses the notification without opening, nothing happens. No "you missed your reflection" message ever.
- If the toggle is off, no notification scheduling code runs.

### Files

- iOS: `Views/About/SettingsView.swift`, `Services/NotificationScheduler.swift`, `Views/Reflection/EveningReflectionSheet.swift`.
- Android: equivalent under `ui/settings/`, `service/NotificationScheduler.kt`, `ui/reflection/EveningReflection.kt`.

### Acceptance

- Toggling on schedules a daily notification at the chosen time; toggling off cancels it.
- Notification fires at the correct local time even after device restart (test with Android `BOOT_COMPLETED` receiver / iOS automatic).
- Tapping notification opens the Evening view.
- Saving in the Evening view writes/updates the same Reflection record as the Reflection tab.

---

## 7. Suggested execution order for Claude Code

Run the phases in order. Each phase should land as a separate PR / branch.

```
phase-1-review-tab
  ├─ rename Calendar tab → Review
  ├─ delete Trends tab, fold its 14-day chart and existing streak into Review
  ├─ add AllTime chart
  ├─ stub Patterns view with empty-state copy
  └─ update tests / smoke tests (including a streak-preservation test)

phase-2-reflection-tab
  ├─ Reflection model + storage migration
  ├─ ReflectionQuestions constant + date-based selector
  ├─ ReflectionView with Today subview (incl. "you've reflected N times" line)
  ├─ By-question subview with collapsible sections + inline content
  ├─ Detail view with previous/next-on-this-question navigation
  ├─ extend Review tab's Calendar: reflection-presence marker on day cells
  ├─ extend Review tab's DayDetail: append reflection region below stones
  ├─ wire into TabView / bottom nav
  └─ tests for date-rotation, persistence, empty-string deletion, prev/next traversal, DayDetail integration

phase-3-stone-tagging
  ├─ add nullable root and intensity fields to Stone, schema migration
  ├─ AddStone sheet: optional root chips + optional intensity chips (two independent rows)
  ├─ StoneDetail / DayDetail: render root and/or intensity labels if present
  └─ migration test on populated DB

phase-4-pattern-surfacing
  ├─ PatternEngine pure function
  ├─ PatternsView wired into Review
  └─ unit tests covering each observation rule

phase-5-evening-closure
  ├─ Settings screen + toggle + time picker
  ├─ NotificationScheduler service
  ├─ EveningReflectionSheet
  ├─ deep-link wiring
  └─ tests with mocked clock
```

### Style / commit conventions for Claude Code

- One conceptual change per commit.
- Commit messages in imperative present tense, prefixed with the phase, e.g. `phase-2: add Reflection model and SwiftData container registration`.
- Keep platform parity: each phase should ship on iOS and Android in the same release window. The two repos can be worked sequentially (iOS first, then Android port) but PRs should reference each other.
- Update each repo's README "Recent Changes" section after each phase.
- Update `White_Stone_app.md` (iOS repo) to reflect the new tab structure once Phase 1 lands.

### Things to flag back to the user before merging

- If migration on the populated user DB fails or risks data loss → stop and surface.
- If a phase requires a new third-party dependency → stop and surface; this project has zero external deps and that should remain true.
- If the user's existing data shape makes any observation rule produce nonsense output → surface examples, don't ship.

---

## 8. Source attribution

- Daily reflection questions: verbatim from *Sacitta Sutta* (AN 10.51), Bhikkhu Sujato translation, SuttaCentral, released under Creative Commons Zero (CC0).
- Root tag taxonomy: drawn from *Dvedhāvitakka Sutta* (MN 19), the Buddha's pre-awakening practice of sorting thoughts into akusala-vitakka and kusala-vitakka.
- Intensity tag: original to this app, intended as a noticing prompt rather than a sutta-derived category.
- Original app inspiration (Upagupta and the white/black pebbles) unchanged from existing README.
