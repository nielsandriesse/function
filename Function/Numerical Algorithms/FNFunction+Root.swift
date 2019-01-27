
extension FNFunction {

    /// Returns an approximation of a root of `self`, as determined by Newton's method.
    /// See [Wikipedia](https://en.wikipedia.org/wiki/Newton%27s_method) for more information.
    ///
    /// - Note: Multivariate functions aren't supported.
    func approximateRoot(startingWithInitialGuess x_i: Double, accuracy: Double) throws -> Double? {
        // Prepare & check preconditions
        var x_i = x_i
        guard !isConstant else { return nil }
        let variables = expression.variables
        guard variables.count == 1 else { throw FNError.multivariateFunction }
        let variable = variables.first!
        // Iterate
        while true {
            let b = try evaluate(for: [ variable : x_i ])
            if abs(b) < accuracy { break }
            let a = try approximateSlope(at: x_i, withAccuracy: accuracy)
            x_i = x_i - b / a
        }
        // Return
        return x_i
    }
}
