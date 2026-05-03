import Foundation

enum ReflectionQuestions {
    static let questions = [
        "Am I often covetous or not?",
        "Am I often malicious or not?",
        "Am I often overcome with dullness and drowsiness or not?",
        "Am I often restless or not?",
        "Am I often doubtful or not?",
        "Am I often irritable or not?",
        "Am I often corrupted in mind or not?",
        "Am I often disturbed in body or not?",
        "Am I often energetic or not?",
        "Am I often immersed in samādhi or not?",
    ]

    static let attributionPrefix = "Daily questions from "
    static let attributionLinkText = "Sacitta Sutta (AN 10.51)"
    static let attributionSuffix = "Translated by Bhikkhu Sujato, SuttaCentral (CC0)."
    static let sourceURL = URL(string: "https://suttacentral.net/an10.51/en/sujato?lang=en&layout=linebyline&reference=main&notes=asterisk&highlight=false&script=latin#3.6")!
    static let attribution = attributionPrefix + attributionLinkText + attributionSuffix

    static func questionForDate(_ date: Date) -> (index: Int, text: String) {
        let dayOfYear = Calendar.current.ordinality(of: .day, in: .year, for: date) ?? 1
        let index = dayOfYear % questions.count
        return (index, questions[index])
    }
}

enum ReflectionDateFormatters {
    static let saveTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMM, h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter
    }()

    static let detailTimestamp: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, d MMMM yyyy h:mma"
        formatter.amSymbol = "am"
        formatter.pmSymbol = "pm"
        return formatter
    }()
}
