import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                TodayView()
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
    }
}
