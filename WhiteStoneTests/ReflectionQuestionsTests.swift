import XCTest
@testable import WhiteStone

final class ReflectionQuestionsTests: XCTestCase {
    func testQuestionForDateUsesDayOfYearModuloQuestionCount() {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(secondsFromGMT: 0)!
        let date = calendar.date(from: DateComponents(
            timeZone: calendar.timeZone,
            year: 2026,
            month: 1,
            day: 1
        ))!

        let question = ReflectionQuestions.questionForDate(date)

        XCTAssertEqual(question.index, 1)
        XCTAssertEqual(question.text, ReflectionQuestions.questions[1])
    }
}
