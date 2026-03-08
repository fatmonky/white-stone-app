import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var allStones: [Stone]

    @State private var selectedTab = 0
    @State private var showWelcome = false
    @State private var showPostFirstEntry = false

    @AppStorage("onboarding.step") private var onboardingStepRaw = ""

    private enum OnboardingStep: String {
        case welcome
        case todayCoach
        case firstLog
        case calendarTour
        case trendsTour
        case completed
    }

    private var onboardingStep: OnboardingStep? {
        get { OnboardingStep(rawValue: onboardingStepRaw) }
        nonmutating set { onboardingStepRaw = newValue?.rawValue ?? "" }
    }

    private var isFreshUser: Bool {
        allStones.isEmpty
    }

    private var shouldShowWelcomeSheet: Bool {
        isFreshUser && onboardingStep == .welcome
    }

    private var shouldShowTodayCoach: Bool {
        isFreshUser && onboardingStep == .todayCoach && selectedTab == 0
    }

    private var shouldShowCalendarTour: Bool {
        onboardingStep == .calendarTour && selectedTab == 1
    }

    private var shouldShowTrendsTour: Bool {
        onboardingStep == .trendsTour && selectedTab == 2
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TodayView(
                    showOnboardingCoach: shouldShowTodayCoach,
                    onCompleteCoach: {
                        onboardingStep = .firstLog
                    },
                    onDismissCoach: {
                        finishOnboarding()
                    },
                    onStoneSaved: {
                        guard onboardingStep == .firstLog else { return }
                        showPostFirstEntry = true
                    }
                )
            }
            .tabItem { Label("Today", systemImage: "circle.fill") }
            .tag(0)

            NavigationStack {
                CalendarView(
                    showTourOverlay: shouldShowCalendarTour,
                    onNextTourStep: {
                        onboardingStep = .trendsTour
                        selectedTab = 2
                    },
                    onSkipTour: finishOnboarding
                )
            }
            .tabItem { Label("Calendar", systemImage: "calendar") }
            .tag(1)

            NavigationStack {
                TrendsView(
                    showTourOverlay: shouldShowTrendsTour,
                    onFinishTour: finishOnboarding,
                    onSkipTour: finishOnboarding
                )
            }
            .tabItem { Label("Trends", systemImage: "chart.line.uptrend.xyaxis") }
            .tag(2)

            NavigationStack {
                AboutView()
            }
            .tabItem { Label("About", systemImage: "info.circle") }
            .tag(3)
        }
        .tint(Color(red: 0.53, green: 0.38, blue: 0.22))
        .onAppear {
            bootstrapOnboardingState()
            syncTabWithOnboardingStep()
        }
        .onChange(of: allStones.count) { _, _ in
            bootstrapOnboardingState()
        }
        .sheet(isPresented: $showWelcome) {
            WelcomeOnboardingSheet(
                onStart: {
                    showWelcome = false
                    onboardingStep = .todayCoach
                    selectedTab = 0
                },
                onSkip: {
                    showWelcome = false
                    finishOnboarding()
                }
            )
        }
        .sheet(isPresented: $showPostFirstEntry) {
            FirstStoneSuccessSheet(
                onContinue: {
                    showPostFirstEntry = false
                    onboardingStep = .calendarTour
                    selectedTab = 1
                },
                onSkip: {
                    showPostFirstEntry = false
                    finishOnboarding()
                }
            )
        }
    }

    private func bootstrapOnboardingState() {
        if isFreshUser {
            if onboardingStep == nil || onboardingStep == .completed {
                onboardingStep = .welcome
            }
            showWelcome = shouldShowWelcomeSheet
            return
        }

        let shouldPreserveOnboardingFlow =
            onboardingStep == .firstLog ||
            onboardingStep == .calendarTour ||
            onboardingStep == .trendsTour ||
            showPostFirstEntry

        if !shouldPreserveOnboardingFlow && onboardingStep != .completed {
            onboardingStep = .completed
        }
        showWelcome = false
        if onboardingStep == .completed {
            showPostFirstEntry = false
        }
    }

    private func syncTabWithOnboardingStep() {
        switch onboardingStep {
        case .calendarTour:
            selectedTab = 1
        case .trendsTour:
            selectedTab = 2
        default:
            break
        }
    }

    private func finishOnboarding() {
        onboardingStep = .completed
        showPostFirstEntry = false
    }
}

private struct WelcomeOnboardingSheet: View {
    let onStart: () -> Void
    let onSkip: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Spacer(minLength: 12)

                Image(systemName: "circle.inset.filled")
                    .font(.system(size: 42))
                    .foregroundStyle(Color(red: 0.53, green: 0.38, blue: 0.22))

                Text("Track your thoughts, one stone at a time.")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text("Log a white stone for a wholesome thought, or log a black stone if the thought was unskillful. Start with logging one stone today, then take a short tour of the Calendar and Trends.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Spacer()

                Button("Start Tour") {
                    onStart()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.53, green: 0.38, blue: 0.22))
                .controlSize(.large)

                Button("Skip") {
                    onSkip()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(24)
            .navigationTitle("Welcome")
            .navigationBarTitleDisplayMode(.inline)
        }
        .interactiveDismissDisabled()
    }
}

private struct FirstStoneSuccessSheet: View {
    let onContinue: () -> Void
    let onSkip: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                Spacer(minLength: 12)

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 44))
                    .foregroundStyle(.green)

                Text("Great. You’ve started today’s record.")
                    .font(.title3.weight(.semibold))
                    .multilineTextAlignment(.center)

                Text("Next, take a quick look at Calendar, then Trends, so you can see how this builds into a pattern.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Spacer()

                Button("Continue to Calendar") {
                    onContinue()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.53, green: 0.38, blue: 0.22))
                .controlSize(.large)

                Button("Finish Without Tour") {
                    onSkip()
                }
                .buttonStyle(.bordered)
                .controlSize(.large)
            }
            .padding(24)
            .navigationTitle("Nice Start")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
