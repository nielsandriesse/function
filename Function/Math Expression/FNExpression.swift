
/// An abstract base class for types that represent a node in an expression tree.
class FNExpression : TreeNode, Hashable {

    // MARK: Tree Node Conformance
    var children: [FNExpression] { return [] }

    // MARK: Initialization
    init() {
        if type(of: self) === FNExpression.self { abstract() }
    }

    // MARK: Evaluation
    func evaluate(for values: [FNVariable:Double]) throws -> Double { abstract() }

    // MARK: General
    var variables: Set<FNVariable> {
        var result = Set<FNVariable>()
        if !children.isEmpty {
            result.formUnion(children.flatMap { $0.variables })
        } else {
            if let variable = self as? FNVariable { result.insert(variable) }
        }
        return result
    }

    var hashValue: Int { abstract() }

    func isEqual(to other: FNExpression) -> Bool { return false }
}

func == (lhs: FNExpression, rhs: FNExpression) -> Bool { return lhs.isEqual(to: rhs) }
