import Foundation

extension String {

    func isNumeric() -> Bool {
        return CharacterSet(charactersIn: self).isSubset(of: CharacterSet.numeric)
    }

    func isNonNumeric() -> Bool {
        return !isNumeric()
    }

    func numericsOnly() -> String {
        return String(self.unicodeScalars.filter { CharacterSet.numeric.contains($0) })
    }
}
