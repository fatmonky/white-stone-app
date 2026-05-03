import SwiftUI
import SwiftData

struct ReflectionView: View {
    @State private var mode: ReflectionMode = .today
    @State private var expandedQuestionIndex: Int?

    var body: some View {
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
}

private enum ReflectionMode {
    case today
    case byQuestion
}
