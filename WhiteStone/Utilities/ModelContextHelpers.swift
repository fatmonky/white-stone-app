import Foundation
import OSLog
import SwiftData

extension ModelContext {
    private static let logger = Logger(subsystem: "com.whitestone.app", category: "persistence")

    /// Fetches and returns an empty array on failure, but logs the error
    /// instead of silently rendering as "no data".
    func fetchOrEmpty<T: PersistentModel>(_ descriptor: FetchDescriptor<T>) -> [T] {
        do {
            return try fetch(descriptor)
        } catch {
            Self.logger.error("Fetch of \(String(describing: T.self)) failed: \(error.localizedDescription)")
            return []
        }
    }
}
