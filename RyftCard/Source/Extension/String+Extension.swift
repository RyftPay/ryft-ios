import Foundation

extension String {

    func isNumeric() -> Bool {
        CharacterSet(charactersIn: self).isSubset(of: CharacterSet.numeric)
    }

    func isNonNumeric() -> Bool {
        !isNumeric()
    }

    func numericsOnly() -> String {
        String(self.unicodeScalars.filter { CharacterSet.numeric.contains($0) })
    }

    func numberOfWords() -> Int {
        self.components(separatedBy: .whitespacesAndNewlines)
            .filter { !$0.isEmpty }
            .count
    }
}
