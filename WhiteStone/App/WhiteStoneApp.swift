import SwiftUI
import SwiftData

@main
struct WhiteStoneApp: App {
    var body: some Scene {
        WindowGroup {
            SplashView()
        }
        .modelContainer(for: Stone.self)
    }
}
