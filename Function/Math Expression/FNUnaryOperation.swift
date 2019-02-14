import Darwin

final class FNUnaryOperation : FNExpression {
    let kind: Kind
    let operand: FNExpression

    // MARK: Tree Node Conformance
    override var children: [FNExpression] { return [ operand ] }

    // MARK: Initialization
    init(kind: Kind, operand: FNExpression) {
        (self.kind, self.operand) = (kind, operand)
    }

    // MARK: Evaluation
    override func evaluate(for values: [FNVariable:Double]) throws -> Double {
        let operandValue = try operand.evaluate(for: values)
        switch kind {
        case .negation: return -operandValue
        case .sine: return sin(operandValue)
        case .cosine: return cos(operandValue)
        case .tangent:
            let result = tan(operandValue)
            if result.isNaN { throw FNError.trigonometricDomain }
            return result
        case .arcSine:
            guard operandValue >= -1 && operandValue <= 1 else { throw FNError.trigonometricDomain }
            return asin(operandValue)
        case .arcCosine:
            guard operandValue >= -1 && operandValue <= 1 else { throw FNError.trigonometricDomain }
            return acos(operandValue)
        case .arcTangent:
            let result = atan(operandValue)
            if result.isNaN { throw FNError.trigonometricDomain }
            return result
        case .naturalLogarithm:
            guard operandValue > 0 else { throw FNError.logarithmicDomain }
            return log(operandValue) / log(Darwin.M_E)
        case .squareRoot:
            guard operandValue >= 0 else { throw FNError.negativeRoot }
            return sqrt(operandValue)
        }
    }

    // MARK: General
    override var hashValue: Int { return kind.hashValue ^ operand.hashValue }

    override func isEqual(to other: FNExpression) -> Bool {
        guard let other = other as? FNUnaryOperation else { return false }
        return kind == other.kind && operand == other.operand
    }
}

extension FNUnaryOperation {

    enum Kind : String {
        case negation = "-", sine = "sin", cosine = "cos", tangent = "tan", arcSine = "asin", arcCosine = "acos", arcTangent = "atan", naturalLogarithm = "ln", squareRoot = "√"

        static let allRawValues: [String] = {
            let kinds: [Kind] = [ .negation, .sine, .cosine, .tangent, arcSine, arcCosine, arcTangent, .naturalLogarithm, .squareRoot ]
            return kinds.map { $0.rawValue }
        }()
    }
}

prefix func -(x: FNExpression) -> FNUnaryOperation { return FNUnaryOperation(kind: .negation, operand: x) }
func sin(_ x: FNExpression) -> FNUnaryOperation { return FNUnaryOperation(kind: .sine, operand: x) }
func cos(_ x: FNExpression) -> FNUnaryOperation { return FNUnaryOperation(kind: .cosine, operand: x) }
func tan(_ x: FNExpression) -> FNUnaryOperation { return FNUnaryOperation(kind: .tangent, operand: x) }
func asin(_ x: FNExpression) -> FNUnaryOperation { return FNUnaryOperation(kind: .arcSine, operand: x) }
func acos(_ x: FNExpression) -> FNUnaryOperation { return FNUnaryOperation(kind: .arcCosine, operand: x) }
func atan(_ x: FNExpression) -> FNUnaryOperation { return FNUnaryOperation(kind: .arcTangent, operand: x) }
func ln(_ x: FNExpression) -> FNUnaryOperation { return FNUnaryOperation(kind: .naturalLogarithm, operand: x) }
func sqrt(_ x: FNExpression) -> FNUnaryOperation { return FNUnaryOperation(kind: .squareRoot, operand: x) }
