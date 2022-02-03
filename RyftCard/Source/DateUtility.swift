import Foundation

final class DateUtility {

    static func currentYear() -> Int {
        let calendar = Calendar(identifier: .gregorian)
        return (calendar.component(.year, from: Date())) % 100
    }
}
