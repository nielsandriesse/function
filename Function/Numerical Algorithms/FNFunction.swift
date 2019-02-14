
struct FNFunction {
    let expression: FNExpression

    var isConstant: Bool { return expression.variables.isEmpty }

    // MARK: Initialization
    init(from expression: FNExpression) {
        self.expression = expression
    }

    init?(fromString string: String) {
        guard let expression = FNExpressionParser(withSource: string).parseExpression() else { return nil }
        self.init(from: expression)
    }

    // MARK: Evaluation
    func evaluate(for values: [FNVariable:Double]) throws -> Double {
        return try expression.evaluate(for: values)
    }

    func evaluate(for values: [String:Double]) throws -> Double {
        let values = values.mapKeys { FNVariable($0) }
        return try evaluate(for: values)
    }
}
