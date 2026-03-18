import Foundation

enum MarkdownPreprocessor {
    static func stripWrapperTags(_ markdown: String) -> String {
        markdown
            .components(separatedBy: .newlines)
            .filter { line in
                let trimmed = line.trimmingCharacters(in: .whitespaces)
                guard !trimmed.isEmpty else { return true }
                return !isWrapperTagLine(trimmed)
            }
            .joined(separator: "\n")
    }

    private static func isWrapperTagLine(_ line: String) -> Bool {
        guard line.hasPrefix("<"), line.hasSuffix(">") else { return false }

        let inner = String(line.dropFirst().dropLast()).trimmingCharacters(in: .whitespaces)
        if inner.hasPrefix("!--") { return true }

        let nameAndRest = inner.hasPrefix("/") ? String(inner.dropFirst()) : inner
        let tagName = nameAndRest.prefix { scalar in
            switch scalar {
            case " ", "\t", "/":
                return false
            default:
                return true
            }
        }

        guard let first = tagName.unicodeScalars.first,
              CharacterSet.letters.contains(first) else {
            return false
        }

        let allowedInName = CharacterSet(charactersIn: "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789:_-")
        return tagName.unicodeScalars.allSatisfy { allowedInName.contains($0) }
    }
}
