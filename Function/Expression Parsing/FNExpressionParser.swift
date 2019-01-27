
// MARK: - Expression Parser

/// See [Parsing Expressions by Precedence Climbing](http://eli.thegreenplace.net/2012/08/02/parsing-expressions-by-precedence-climbing) for more information.
final class FNExpressionParser {
    private var tokenIterator: PeekingIterator<FNTokenIterator>

    // MARK: Initialization
    init(withSource source: String) {
        self.tokenIterator = PeekingIterator(wrapping: FNTokenIterator(withSource: source))
    }

    // MARK: Implementation
    func parseExpression() -> FNExpression? {
        let result = _parseExpression()
        guard tokenIterator.peek() == nil else { return nil } // Check that we reached the end of the source
        return result
    }

    // If callingOperation is non-nil, its right-hand operand is the thing being parsed
    private func _parseExpression(callingOperation: _BinaryOperation? = nil) -> FNExpression? {
        guard var result = parseAtom() else { return nil }
        while let nextToken = tokenIterator.peek(), case let .binaryOperation(kind) = nextToken {
            let binaryOperation = _BinaryOperation(from: kind)
            // At this point (if callingOperation is non-nil), we have either `(exp calling-op result) binop exp` or `exp calling-op (result binop exp)`.
            // In the first case, the loop can be exited because callingOperation's right-hand operand has already been fully parsed
            if let callingOperation = callingOperation, !binaryOperation.executesBefore(precedingOperation: callingOperation) { break }
            // Consume token
            tokenIterator.next()
            // Update result
            guard let rhs = _parseExpression(callingOperation: binaryOperation) else { return nil }
            result = FNBinaryOperation(kind: binaryOperation.kind, lhs: result, rhs: rhs)
        }
        return result
    }

    private func parseAtom() -> FNExpression? {
        guard let token = tokenIterator.next() else { return nil }
        switch token {
        case let .value(valueAsString):
            guard let valueAsDouble = Double(valueAsString) else { return nil }
            return FNValue(valueAsDouble)
        case let .constant(type):
            switch type {
            case .π: return FNConstant.π
            case .e: return FNConstant.e
            }
        case let .variable(symbol): return FNVariable(symbol)
        case let .unaryOperation(kind):
            let unaryOperation = _UnaryOperation(from: kind)
            // Check for parentheses if required
            if unaryOperation.requiresParentheses {
                let isNextTokenLeftParenthesis = given(tokenIterator.peek()) { isToken($0, bracketOfType: .leftParenthesis) } ?? false
                if !isNextTokenLeftParenthesis { return nil }
            }
            guard let operand = parseAtom() else { return nil }
            return FNUnaryOperation(kind: unaryOperation.kind, operand: operand)
        case .binaryOperation(_): return nil
        case let .bracket(type):
            switch type {
            case .leftParenthesis, .leftSquare:
                let content = _parseExpression()
                guard isNextTokenClosingBracket(forLeftBracketOfType: type) else { return nil }
                return content
            case .rightParenthesis, .rightSquare: return nil
            }
        case .comma(_): return nil
        }
    }

    private func isToken(_ token: FNToken, bracketOfType type: BracketType) -> Bool {
        switch token {
        case let .bracket(x) where x == type: return true
        default: return false
        }
    }

    private func isNextTokenClosingBracket(forLeftBracketOfType type: BracketType) -> Bool {
        return given(tokenIterator.next()) { isToken($0, bracketOfType: type.matchingBracket) } ?? false
    }

    private func advanceIteratorIfTokenIsComma(_ token: FNToken) -> Bool {
        switch token {
        case .comma:
            tokenIterator.next()
            return true
        default: return false
        }
    }
}



// MARK: - Unary Operation

private struct _UnaryOperation {
    let kind: FNUnaryOperation.Kind
    let precedence: Precedence
    let requiresParentheses: Bool

    init(from kind: FNUnaryOperation.Kind) {
        (self.kind, self.precedence, self.requiresParentheses) = {
            switch kind {
            case .negation: return (.negation, .sign, false)
            case .sine: return (.sine, .function, true)
            case .cosine: return (.cosine, .function, true)
            case .tangent: return (.tangent, .function, true)
            case .arcSine: return (.arcSine, .function, true)
            case .arcCosine: return (.arcCosine, .function, true)
            case .arcTangent: return (.arcTangent, .function, true)
            case .naturalLogarithm: return (.naturalLogarithm, .function, true)
            case .squareRoot: return (.squareRoot, .function, true)
            }
        }()
    }
}



// MARK: - Binary Operation

private struct _BinaryOperation {
    let kind: FNBinaryOperation.Kind
    let precedence: Precedence
    let associativity: Associativity

    init(from kind: FNBinaryOperation.Kind) {
        (self.kind, self.precedence, self.associativity) = {
            switch kind {
            case .addition: return (.addition, .additionSubtraction, .leftAssociative)
            case .subtraction: return (.subtraction, .additionSubtraction, .leftAssociative)
            case .multiplication: return (.multiplication, .multiplicationDivision, .leftAssociative)
            case .division: return (.division, .multiplicationDivision, .leftAssociative)
            case .exponentiation: return (.exponentiation, .exponentiation, .rightAssociative)
            }
        }()
    }

    func executesBefore(precedingOperation: _BinaryOperation) -> Bool {
        if precedence == precedingOperation.precedence { return associativity == .rightAssociative }
        return precedence > precedingOperation.precedence
    }
}



// MARK: - Precedence

private enum Precedence: Int, Comparable {
    case additionSubtraction, multiplicationDivision, function, sign, exponentiation
}

private func < (lhs: Precedence, rhs: Precedence) -> Bool { return lhs.rawValue < rhs.rawValue }



// MARK: - Associativity

private enum Associativity {
    case associative, leftAssociative, rightAssociative, nonAssociative
}
