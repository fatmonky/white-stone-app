# AGENTS.md

## Project

White Stone is a native iOS app for tracking wholesome and unwholesome thoughts/actions as white and black stones. Keep the app quiet, local-first, and contemplative. Do not add analytics, telemetry, badges, achievements, streak milestones, notifications, or gamified copy unless explicitly requested.

## Stack

- SwiftUI, iOS 17+
- SwiftData for local storage
- Swift Charts
- XcodeGen via `project.yml`
- No third-party app dependencies
- Fastlane is present for App Store/TestFlight release work

## Important Files

- App entry: `WhiteStone/App/WhiteStoneApp.swift`
- Main tabs and onboarding: `WhiteStone/Views/ContentView.swift`
- Today flow: `WhiteStone/Views/Today/TodayView.swift`
- Add stone sheet: `WhiteStone/Views/AddStone/AddStoneSheet.swift`
- Review tab: `WhiteStone/Views/Review/ReviewView.swift`
- Pattern observations: `WhiteStone/Utilities/PatternEngine.swift`
- Reflections: `WhiteStone/Views/Reflection/`
- Models: `WhiteStone/Models/Stone.swift`, `WhiteStone/Models/Reflection.swift`
- Tests: `WhiteStoneTests/`

## Build And Test

Regenerate the Xcode project after changing `project.yml`:

```bash
xcodegen generate
```

Build:

```bash
xcodebuild -project WhiteStone.xcodeproj -scheme WhiteStone -destination 'platform=iOS Simulator,name=iPhone 17' build
```

Run tests:

```bash
xcodebuild -project WhiteStone.xcodeproj -scheme WhiteStone -destination 'platform=iOS Simulator,name=iPhone 17' test
```

If `iPhone 17` is unavailable, list simulators and use the closest available iPhone simulator.

## Implementation Rules

- Follow existing SwiftUI patterns; do not introduce a ViewModel layer unless the change clearly needs it.
- Prefer targeted SwiftData fetches and date intervals over broad full-table filtering.
- Do not rely on stored `dayKey` for view grouping when timestamp intervals are safer.
- Keep `Stone.timestamp` and `dayKey` in sync.
- Keep stone root tags constrained by stone color.
- Keep pattern observations local-only, low-emphasis, and capped.
- Prefer first-party Apple frameworks already used in the repo.

## Onboarding Rules

The current onboarding flow is:

```text
welcome -> todayCoach -> firstLog -> reviewTour -> reflectionsTour -> completed
```

Rules:

- Onboarding state is stored in `@AppStorage("onboarding.step")`.
- Fresh users with no stones start at `welcome`.
- Existing users with stones should not see onboarding.
- Completed onboarding must not restart if the user later deletes all stones.
- Preserve mid-flow states: `firstLog`, `reviewTour`, `reflectionsTour`.
- Sync `reviewTour` to the Review tab and `reflectionsTour` to the Reflections tab.
- Today coach sub-step is local UI state and should reset when re-shown.
- Tour overlays should block underlying content interaction.
- Keep onboarding copy calm and practical.

## UI Tone

- Use the existing white/black/brown visual language.
- Avoid green/red judgment framing except where already used for system confirmation.
- Avoid flashy celebration language.
- Keep copy plain, reflective, and non-coercive.

## Completion Workflow

After implementing any plan or completing a goal:

- Run the relevant build and tests.
- Run the app in the iOS Simulator.
- Leave the simulator open so the human can inspect the revised app.
- Navigate the simulator to the changed area when practical.
- Capture screenshots of the changed flow or screens and save them under `docs/session-artifacts/` or another clearly named repo-local folder.
- Document the work in a markdown file under `docs/session-notes/`.
- Write a draft blog entry in a markdown file under `docs/blog-drafts/`.
- Include links or relative paths to the screenshots in both markdown files when screenshots are relevant.
- Mention any verification steps that could not be completed.

Suggested filenames:

```text
docs/session-notes/YYYY-MM-DD-short-description.md
docs/blog-drafts/YYYY-MM-DD-short-description.md
docs/session-artifacts/YYYY-MM-DD-short-description-01.png
```

## Release Notes

Fastlane lanes live in `fastlane/Fastfile`.

- `bundle exec fastlane ios upload_only` builds and uploads to TestFlight.
- `bundle exec fastlane ios release` builds, uploads, and submits for review.
- Release lanes require `ASC_KEY_PATH`.

## Git Workflow

Before committing:

```bash
git status --short
git diff --stat
```

Stage only files in scope. If commit signing fails with a 1Password buffer error, retry with:

```bash
git -c commit.gpgsign=false commit -m "message"
```

Only push when explicitly requested.
