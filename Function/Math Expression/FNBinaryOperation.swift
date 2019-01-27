import Darwin

final class FNBinaryOperation : FNExpression {
	let kind: Kind
	let lhs, rhs: FNExpression

	// MARK: Tree Node Conformance
	override var children: [FNExpression] { return [ lhs, rhs ] }

	// MARK: Initialization
	init(kind: Kind, lhs: FNExpression, rhs: FNExpression) {
		(self.kind, self.lhs, self.rhs) = (kind, lhs, rhs)
	}

	// MARK: Evaluation
	override func evaluate(for values: [FNVariable:Double]) throws -> Double {
		let lhsValue = try lhs.evaluate(for: values)
		let rhsValue = try rhs.evaluate(for: values)
		switch kind {
		case .addition: return lhsValue + rhsValue
		case .subtraction: return lhsValue - rhsValue
		case .multiplication: return lhsValue * rhsValue
		case .division:
			guard rhsValue != 0 else { throw FNError.divisionByZero }
			return lhsValue / rhsValue
		case .exponentiation:
			if lhsValue < 0 && rhsValue != rhsValue.rounded(.down) { throw FNError.negativeRoot }
			if lhsValue == 0 && rhsValue < 0 { throw FNError.divisionByZero }
            return pow(lhsValue, rhsValue)
		}
	}

	// MARK: General
	override var hashValue: Int { return kind.hashValue ^ lhs.hashValue ^ rhs.hashValue }

    override func isEqual(to other: FNExpression) -> Bool {
        guard let other = other as? FNBinaryOperation else { return false }
        return kind == other.kind && lhs == other.lhs && rhs == other.rhs
    }
}

extension FNBinaryOperation {

    enum Kind : Character {
        case addition = "+", subtraction = "-",  multiplication = "*", division = "/", exponentiation = "^"
    }
}

func + (lhs: FNExpression, rhs: FNExpression) -> FNBinaryOperation { return FNBinaryOperation(kind: .addition, lhs: lhs, rhs: rhs) }
func - (lhs: FNExpression, rhs: FNExpression) -> FNBinaryOperation { return FNBinaryOperation(kind: .subtraction, lhs: lhs, rhs: rhs) }
func * (lhs: FNExpression, rhs: FNExpression) -> FNBinaryOperation { return FNBinaryOperation(kind: .multiplication, lhs: lhs, rhs: rhs) }
func / (lhs: FNExpression, rhs: FNExpression) -> FNBinaryOperation { return FNBinaryOperation(kind: .division, lhs: lhs, rhs: rhs) }
func pow(lhs: FNExpression, rhs: FNExpression) -> FNBinaryOperation { return FNBinaryOperation(kind: .exponentiation, lhs: lhs, rhs: rhs) }
