import SwiftUI
import SwiftData

struct ContentView: View {
    @Query private var allStones: [Stone]

    @State private var selectedTab = 0
    @State private var showWelcome = false
    @State private var showPostFirstEntry = false
    @State private var manuallyShowCoach = false
    @State private var didIncrementLaunchCount = false

    @AppStorage("onboarding.hasSeenWelcome") private var hasSeenWelcome = false
    @AppStorage("onboarding.hasSeenTodayCoach") private var hasSeenTodayCoach = false
    @AppStorage("onboarding.hasLoggedFirstStone") private var hasLoggedFirstStone = false
    @AppStorage("onboarding.hasSeenPostFirstEntry") private var hasSeenPostFirstEntry = false
    @AppStorage("onboarding.didDismissOnboarding") private var didDismissOnboarding = false
    @AppStorage("onboarding.hasDismissedFeatureNudge") private var hasDismissedFeatureNudge = false
    @AppStorage("onboarding.launchCount") private var launchCount = 0
    @AppStorage("onboarding.version") private var onboardingVersion = 0

    private let currentOnboardingVersion = 1

    private var isFreshUser: Bool {
        allStones.isEmpty
    }

    private var shouldShowWelcomeSheet: Bool {
        isFreshUser && !hasSeenWelcome
    }

    private var shouldShowTodayCoach: Bool {
        guard isFreshUser, hasSeenWelcome, !hasSeenTodayCoach, selectedTab == 0 else {
            return false
        }
        return !didDismissOnboarding || manuallyShowCoach
    }

    private var shouldShowTourButton: Bool {
        isFreshUser && hasSeenWelcome && !hasSeenTodayCoach && didDismissOnboarding
    }

    private var featureNudgeMessage: String? {
        guard hasLoggedFirstStone, !hasDismissedFeatureNudge else {
            return nil
        }
        if launchCount == 2 {
            return "Calendar shows your day-by-day pattern."
        }
        if launchCount == 3 {
            return "Trends shows your streak and 14-day chart."
        }
        return nil
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TodayView(
                    showOnboardingCoach: shouldShowTodayCoach,
                    showTourButton: shouldShowTourButton,
                    useFirstLogNotePrompt: !hasLoggedFirstStone,
                    featureNudgeMessage: featureNudgeMessage,
                    onCompleteCoach: {
                        hasSeenTodayCoach = true
                        didDismissOnboarding = false
                        manuallyShowCoach = false
                    },
                    onDismissCoach: {
                        didDismissOnboarding = true
                        manuallyShowCoach = false
                    },
                    onStartTour: {
                        selectedTab = 0
                        didDismissOnboarding = false
                        manuallyShowCoach = true
                    },
                    onStoneSaved: {
                        if !hasLoggedFirstStone {
                            hasLoggedFirstStone = true
                        }
                        if !hasSeenPostFirstEntry {
                            showPostFirstEntry = true
                        }
                    },
                    onDismissFeatureNudge: {
                        hasDismissedFeatureNudge = true
                    }
                )
            }
            .tabItem { Label("Today", systemImage: "circle.fill") }
            .tag(0)

            NavigationStack {
                CalendarView()
            }
            .tabItem { Label("Calendar", systemImage: "calendar") }
            .tag(1)

            NavigationStack {
                TrendsView()
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
        .onAppear(perform: bootstrapOnboardingState)
        .onChange(of: allStones.count) { _, _ in
            bootstrapOnboardingState()
        }
        .sheet(isPresented: $showWelcome) {
            WelcomeOnboardingSheet(
                onStart: {
                    hasSeenWelcome = true
                    didDismissOnboarding = false
                    selectedTab = 0
                    showWelcome = false
                },
                onSkip: {
                    hasSeenWelcome = true
                    didDismissOnboarding = true
                    selectedTab = 0
                    showWelcome = false
                }
            )
        }
        .sheet(isPresented: $showPostFirstEntry) {
            FirstStoneSuccessSheet(
                onViewToday: {
                    hasSeenPostFirstEntry = true
                    showPostFirstEntry = false
                    selectedTab = 0
                },
                onExplore: {
                    hasSeenPostFirstEntry = true
                    showPostFirstEntry = false
                    selectedTab = 1
                }
            )
        }
    }

    private func bootstrapOnboardingState() {
        if onboardingVersion != currentOnboardingVersion {
            onboardingVersion = currentOnboardingVersion
        }

        if !didIncrementLaunchCount {
            launchCount += 1
            didIncrementLaunchCount = true
        }

        if !allStones.isEmpty {
            hasLoggedFirstStone = true
            hasSeenWelcome = true
            hasSeenTodayCoach = true
            didDismissOnboarding = false
            manuallyShowCoach = false
            showWelcome = false
            return
        }

        if shouldShowWelcomeSheet {
            showWelcome = true
        }
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

                Text("White and black can mean whatever you choose. Start with one quick log today.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Spacer()

                Button("Start") {
                    onStart()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.53, green: 0.38, blue: 0.22))
                .controlSize(.large)

                Button("Not now") {
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
    let onViewToday: () -> Void
    let onExplore: () -> Void

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

                Text("Keep adding stones through the day, then review patterns in Calendar and Trends.")
                    .font(.callout)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 8)

                Spacer()

                Button("View Today") {
                    onViewToday()
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.53, green: 0.38, blue: 0.22))
                .controlSize(.large)

                Button("See Calendar & Trends") {
                    onExplore()
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
