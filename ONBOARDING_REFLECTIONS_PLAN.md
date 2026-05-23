# Reflections Onboarding Plan

## Goal

Add a Reflections tab review to the existing first-run onboarding flow.

Current flow:

```text
welcome -> todayCoach -> firstLog -> reviewTour -> completed
```

Target flow:

```text
welcome -> todayCoach -> firstLog -> reviewTour -> reflectionsTour -> completed
```

## Implementation Plan

1. Update onboarding state in `WhiteStone/Views/ContentView.swift`.
   - Add `OnboardingStep.reflectionsTour`.
   - Keep the existing steps unchanged.

2. Add a Reflections tour visibility guard in `ContentView`.
   - Add:

   ```swift
   private var shouldShowReflectionsTour: Bool {
       onboardingStep == .reflectionsTour && selectedTab == 2
   }
   ```

   - This should mirror the existing `shouldShowReviewTour` guard.

3. Route Review completion to Reflections.
   - Change `ReviewView` wiring so `onFinishTour` advances to `.reflectionsTour` and selects tab `2`.
   - Keep `onSkipTour` wired to `finishOnboarding()`.
   - Rename the Review overlay button from `Finish Tour` to `Continue to Reflections`.

4. Preserve onboarding mid-flow.
   - Update `bootstrapOnboardingState()` so `.reflectionsTour` is included in `shouldPreserveOnboardingFlow`.
   - This prevents onboarding from auto-completing if the user relaunches after logging a stone but before finishing the Reflections tour.

5. Restore the correct tab on relaunch.
   - Update `syncTabWithOnboardingStep()`:
     - `.reviewTour` selects tab `1`.
     - `.reflectionsTour` selects tab `2`.

6. Add tour support to `WhiteStone/Views/Reflection/ReflectionView.swift`.
   - Add parameters:

   ```swift
   var showTourOverlay: Bool = false
   var onFinishTour: () -> Void = {}
   var onSkipTour: () -> Void = {}
   ```

   - Wrap the existing mode content in a `ZStack`.
   - Keep `.navigationTitle("Reflections")` and `.toolbar` on the outer `ZStack`, so the nav bar and Daily/Questions toggle continue to render correctly.
   - Apply `.allowsHitTesting(!showTourOverlay)` to the main content.
   - Match the existing `ReviewView` overlay behavior: the nav toolbar may remain tappable while the tour card is visible.

7. Add a Reflections tour card.
   - Add a `tourOverlay` in `ReflectionView`, visually consistent with `ReviewView`.
   - Cover:
     - Daily reflection question.
     - Optional saved response.
     - Questions view for revisiting past answers by prompt.
     - Review calendar markers for saved reflections.
   - Buttons:
     - `Finish Tour` calls `onFinishTour()`.
     - `Skip Tour` calls `onSkipTour()`.

8. Wire the Reflections tour from `ContentView`.
   - Replace `ReflectionView()` with:

   ```swift
   ReflectionView(
       showTourOverlay: shouldShowReflectionsTour,
       onFinishTour: finishOnboarding,
       onSkipTour: finishOnboarding
   )
   ```

   - Finishing or skipping from Reflections should leave the user on the Reflections tab.

9. Update onboarding copy.
   - Welcome sheet: mention that the tour covers Today, Review, and Reflections.
   - First-stone success sheet: mention Review first, then Reflections.
   - Rename the first-stone button from `Continue to Review` to `Continue Tour`.

## Verification Checklist

- Fresh install or cleared `onboarding.step` follows:

  ```text
  Welcome -> Today coach -> first stone success -> Review overlay -> Reflections overlay -> completed
  ```

- Skip from Welcome completes onboarding.
- Skip from the post-first-entry sheet completes onboarding.
- Skip from Review completes onboarding.
- Finish from Review advances to Reflections.
- Finish from Reflections completes onboarding and leaves the user on tab `2`.
- Skip from Reflections completes onboarding and leaves the user on tab `2`.
- Relaunch while `onboarding.step == reviewTour` restores the Review tab.
- Relaunch while `onboarding.step == reflectionsTour` restores the Reflections tab.
- Existing returning users are not re-onboarded.

