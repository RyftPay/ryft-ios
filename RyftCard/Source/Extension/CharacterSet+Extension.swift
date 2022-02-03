import Foundation

extension CharacterSet {

    static let numeric = CharacterSet(charactersIn: "0123456789")
    static let nonNumeric = numeric.inverted
}
