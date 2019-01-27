
final class FNTokenIterator : IteratorProtocol {
    private let source: String
    private var nextIndex: String.Index
    private var currentToken: FNToken?
    private var currentIndex: String.Index { return source.index(before: nextIndex) }

    init(withSource source: String) {
        (self.source, self.nextIndex) = (source, source.startIndex)
    }

    func next() -> FNToken? {
        currentToken = consumeToken()
        return currentToken
    }

    @discardableResult
    private func consumeCharacter() -> Character? {
        if nextIndex == source.endIndex { return nil }
        let character = source[nextIndex]
        nextIndex = source.index(after: nextIndex)
        return character
    }

    private func peekCharacter() -> Character? {
        if nextIndex == source.endIndex { return nil }
        return source[nextIndex]
    }

    private func consumeToken() -> FNToken? {
        // The order of these calls is important
        while let character = consumeCharacter() {
            if character == " " || character == "\t" { continue } // Ignore white space
            if let value = parseValue(startingWith: character) { return .value(value) }
            if let constantType = ConstantType(rawValue: character) { return .constant(constantType) }
            if let unaryOperationKind = parseUnaryOperationKind() { return .unaryOperation(unaryOperationKind) }
            if let variable = parseVariable(startingWith: character) { return .variable(variable) }
            if let binaryOperationKind = FNBinaryOperation.Kind(rawValue: character) { return .binaryOperation(binaryOperationKind) }
            if let bracketType = BracketType(rawValue: character) { return .bracket(bracketType) }
            if let comma = parseComma(from: character) { return .comma(comma) }
            fatalError("Unexpected character: \"\(character)\" in source: \"\(source)\".")
        }
        return nil
    }

    private func parseValue(startingWith startingCharacter: Character) -> String? {
        // Prepare
        let digits: ClosedRange<Character> = "0"..."9"
        guard digits ~= startingCharacter else { return nil }
        var result = String(startingCharacter)
        var currentCharacter = startingCharacter
        // Convenience
        func isAcceptedCharacter(_ character: Character) -> Bool {
            let isExponentMinus = (character == "-" && currentCharacter == "e")
            return digits.contains(character) || character == "e" || character == "." || isExponentMinus
        }
        // Keep appending characters to the result until we either reach
        // the end of the source or find a character that isn't accepted
        while let character = peekCharacter() {
            guard isAcceptedCharacter(character) else { break }
            result.append(character)
            currentCharacter = consumeCharacter()! // Safe because we just checked peekCharacter()
        }
        // Return
        return result
    }

    private func parseVariable(startingWith startingCharacter: Character) -> String? {
        // Convenience
        func isAcceptedCharacter(_ character: Character) -> Bool {
            // The "µ" is a micro sign (not a mu) and the "‑" is a non-breaking hyphen (not a minus)
            return "a"..."z" ~= character || "A"..."Z" ~= character || "0"..."9" ~= character ||
                "α"..."ω" ~= character || "Α"..."Ω" ~= character || character == "_" || character == "°" ||
                character == "µ" || character == "'" || character == "\"" || character == "‑"
        }
        // Prepare
        guard isAcceptedCharacter(startingCharacter) else { return nil }
        var result = String(startingCharacter)
        // Keep appending characters to the result until we either reach
        // the end of the source or find a character that isn't accepted
        while let character = peekCharacter() {
            guard isAcceptedCharacter(character) else { break }
            result.append(character)
            consumeCharacter()
        }
        // Return
        return result
    }

    private func parseComma(from character: Character) -> String? {
        return character == "," ? String(character) : nil
    }

    private func parseUnaryOperationKind() -> FNUnaryOperation.Kind? {
        // Prepare
        let rest = source[currentIndex...]
        guard let rawValue = FNUnaryOperation.Kind.allRawValues.first(where: { rest.hasPrefix($0) }) else { return nil }
        guard !(rawValue == "-" && !shouldMinusBeUnary()) else { return nil } // Subtraction
        // Advance to the next token
        for _ in 0..<(rawValue.count - 1) { consumeCharacter() }
        // Return
        return FNUnaryOperation.Kind(rawValue: rawValue)
    }

    private func shouldMinusBeUnary() -> Bool {
        guard let currentToken = currentToken else { return true } // Start of the source
        switch currentToken {
        case .binaryOperation: return true
        case let .bracket(type):
            switch type {
            case .leftParenthesis, .leftSquare: return true
            case .rightParenthesis, .rightSquare: return false
            }
        case let .unaryOperation(kind) where kind == .negation: return true
        default: return false
        }
    }
}
