import Foundation
import SwiftData

@Model
final class Reflection {
    var date: Date
    var questionIndex: Int
    var responseText: String
    var createdAt: Date
    var updatedAt: Date?

    init(
        date: Date,
        questionIndex: Int,
        responseText: String,
        createdAt: Date = .now
    ) {
        self.date = Calendar.current.startOfDay(for: date)
        self.questionIndex = questionIndex
        self.responseText = responseText
        self.createdAt = createdAt
        self.updatedAt = createdAt
    }
}
