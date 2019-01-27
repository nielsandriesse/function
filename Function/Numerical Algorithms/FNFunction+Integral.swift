
extension FNFunction {

    /// Returns an approximation of the integral of `self` over `interval`, as determined by using the rectangle rule with `n` steps.
    /// See [Wikipedia](http://en.wikipedia.org/wiki/Numerical_integration#Quadrature_rules_based_on_interpolating_functions) for more information.
    ///
    /// - Note: Multivariate functions aren't supported.
    func approximateIntegral(over interval: ClosedRange<Double>, withNumberOfSteps n: Int) throws -> Double {
        // Prepare & check preconditions
        guard n > 0 else { throw FNError.invalidNumberOfSteps }
        let (a, b) = (interval.lowerBound, interval.upperBound)
        guard b > a else { throw FNError.invalidSearchInterval }
        guard !interval.isEmpty else { return 0 }
        let d_x = (b - a) / Double(n)
        guard d_x > 0 else { throw FNError.maximumPrecisionExceeded }
        guard !isConstant else {
            let y = try evaluate(for: [ "x" : 0 ]) // Dummy variable to resolve the ambiguity between the different evaluate(for:) implementations
            return y * (b - a)
        }
        let variables = expression.variables
        guard variables.count == 1 else { throw FNError.multivariateFunction }
        let variable = variables.first!
        // Iterate
        var x_i = a + d_x / 2
        var result = try evaluate(for: [ variable : x_i ])
        for _ in 1..<n {
            x_i = x_i + d_x
            result += try evaluate(for: [variable : x_i ])
        }
        // Multiply with d_x (do afterwards to minimize rounding error)
        result *= d_x
        // Return
        return result
    }
}
