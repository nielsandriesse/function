
enum FNToken : CustomStringConvertible {
    case value(String)
    case constant(ConstantType)
    case variable(String)
    case unaryOperation(FNUnaryOperation.Kind)
    case binaryOperation(FNBinaryOperation.Kind)
    case bracket(BracketType)
    case comma(String)

    var description: String {
        switch self {
        case let .value(value): return "value(\(value))"
        case let .constant(constant): return "constant(\(constant.rawValue))"
        case let .variable(variable): return "variable(\(variable))"
        case let .unaryOperation(unaryOperation): return "unaryOperation(\(unaryOperation.rawValue))"
        case let .binaryOperation(binaryOperation): return "binaryOperation(\(binaryOperation.rawValue))"
        case let .bracket(bracket): return "bracket(\(bracket.rawValue))"
        case let .comma(comma): return "comma(\(comma))"
        }
    }
}

enum ConstantType : Character { case π = "π", e = "e" }

enum BracketType : Character {
    case leftParenthesis = "(", leftSquare = "[", rightParenthesis = ")", rightSquare = "]"

    var matchingBracket: BracketType {
        switch self {
        case .leftParenthesis: return .rightParenthesis
        case .leftSquare: return .rightSquare
        case .rightParenthesis: return .leftParenthesis
        case .rightSquare: return .leftSquare
        }
    }
}
