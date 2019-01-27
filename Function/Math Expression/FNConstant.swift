import Darwin

final class FNConstant : FNExpression {
	let symbol: String
	let value: FNExpression

	// MARK: Initialization
	init(symbol: String, value: FNExpression) {
		(self.symbol, self.value) = (symbol, value)
	}

	static var π = FNConstant(symbol: "π", value: FNValue(Double.pi))
	static var e = FNConstant(symbol: "e", value: FNValue(Darwin.M_E))

	// MARK: Evaluation
	override func evaluate(for values: [FNVariable:Double]) throws -> Double {
		return try value.evaluate(for: values)
	}

	// MARK: General
	override var hashValue: Int { return symbol.hashValue ^ value.hashValue }

    override func isEqual(to other: FNExpression) -> Bool {
        guard let other = other as? FNConstant else { return false }
        return symbol == other.symbol && value == other.value
    }
}
