import SwiftUI
import SwiftData

struct ReflectionView: View {
    var showTourOverlay: Bool = false
    var onFinishTour: () -> Void = {}
    var onSkipTour: () -> Void = {}

    @State private var mode: ReflectionMode = .today
    @State private var expandedQuestionIndex: Int?

    var body: some View {
        ZStack {
            Group {
                switch mode {
                case .today:
                    ReflectionTodayView(
                        onOpenQuestionHistory: { index in
                            expandedQuestionIndex = index
                            mode = .byQuestion
                        }
                    )
                case .byQuestion:
                    ByQuestionView(expandedQuestionIndex: $expandedQuestionIndex)
                }
            }
            .allowsHitTesting(!showTourOverlay)

            if showTourOverlay {
                tourOverlay
            }
        }
        .navigationTitle("Reflections")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        mode = mode == .today ? .byQuestion : .today
                    }
                } label: {
                    VStack(spacing: 1) {
                        Image(systemName: mode == .today ? "questionmark.bubble" : "square.and.pencil")
                            .font(.title3)
                        Text(mode == .today ? "Questions" : "Daily")
                            .font(.caption2)
                    }
                }
                .accessibilityLabel(mode == .today ? "Questions View" : "Daily View")
            }
        }
    }

    private var tourOverlay: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()

            VStack(spacing: 14) {
                Spacer(minLength: 180)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Reflections")
                        .font(.headline)

                    Text("Reflections gives you one daily question and a quiet place to save a response. Use Questions to revisit past answers by prompt; saved reflections also appear as markers in Review.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Button("Finish Tour") {
                        onFinishTour()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(Color(red: 0.53, green: 0.38, blue: 0.22))

                    Button("Skip Tour") {
                        onSkipTour()
                    }
                    .buttonStyle(.bordered)
                }
                .padding(16)
                .frame(maxWidth: 320)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color.white.opacity(0.98))
                )
                .shadow(color: .black.opacity(0.08), radius: 18, y: 8)

                Spacer()
            }
        }
    }
}

private enum ReflectionMode {
    case today
    case byQuestion
}
