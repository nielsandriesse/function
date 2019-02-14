
final class FNValue : FNExpression, ExpressibleByFloatLiteral, Comparable {
    let value: Double

    // MARK: Initialization
    init(_ value: Double) { self.value = value }
    required init(floatLiteral value: Double) { self.value = value }

    // MARK: Evaluation
    override func evaluate(for values: [FNVariable:Double]) -> Double { return value }

    // MARK: General
    override var hashValue: Int { return value.hashValue }

    override func isEqual(to other: FNExpression) -> Bool {
        guard let other = other as? FNValue else { return false }
        return value == other.value
    }
}

func < (lhs: FNValue, rhs: FNValue) -> Bool { return lhs.value < rhs.value }
