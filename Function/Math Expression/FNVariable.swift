
final class FNVariable : FNExpression {
    let symbol: String

    // MARK: Initialization
    init(_ symbol: String) { self.symbol = symbol }

    // MARK: Evaluation
    override func evaluate(for values: [FNVariable:Double]) throws -> Double {
        guard let value = values[self] else { throw FNError.missingVariable }
        return value
    }

    // MARK: General
    override var hashValue: Int { return symbol.hashValue }

    override func isEqual(to other: FNExpression) -> Bool {
        guard let other = other as? FNVariable else { return false }
        return symbol == other.symbol
    }
}
