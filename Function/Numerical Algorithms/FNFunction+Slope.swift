import Darwin

extension FNFunction {

    /// Returns the approximate slope of `self` between `p_1` and `p_2`.
    ///
    /// - Note: For univariate functions, see `approximateSlope(at:withAccuracy)`.
    func approximateSlope(between p_1: [String:Double], and p_2: [String:Double], withAccuracy accuracy: Double) throws -> Double {
        let v_1 = try evaluate(for: p_1)
        let v_2 = try evaluate(for: p_2)
        let d = sqrt(zip(p_1.values, p_2.values).map { pow($1 - $0, 2) }.reduce(0, +))
        let s = (v_2 - v_1) / d
        if abs(s) < accuracy { return 0 } // Round if necessary
        return s
    }

    /// Returns the approximate slope of `self` at `x` by taking the symmetric difference quotient.
    /// See [Wikipedia](http://en.wikipedia.org/wiki/Numerical_differentiation) for more information.
    ///
    /// - Note: In cases where `f(x+h)` or `f(x-h)` failed to evaluate (but not both), Newton's
    /// difference quotient is used as a fallback method to still achieve a result.
    ///
    /// - Note: For multivariate functions, see `approximateSlope(between:and:withAccuracy)`.
    func approximateSlope(at x: Double, withAccuracy accuracy: Double) throws -> Double {
        let variables = expression.variables
        guard let variable = variables.first else { return 0 }
        guard variables.count == 1 else { throw FNError.multivariateFunction }
        // Calculate f(x)
        let y = try evaluate(for: [ variable : x ])
        // Determine x1 and x2
        let ε = max(x.nextUp - x, y.nextUp - y)
        let h = sqrt(ε)
        var (x_1, x_2) = (x - h, x + h)
        // Calculate f(x1) and f(x2)
        var y_1: Double! = try? evaluate(for: [ variable : x_1 ])
        var y_2: Double! = try? evaluate(for: [ variable : x_2 ])
        // Check the results. If both points failed to evaluate, we can't proceed. If just one point failed
        // to evaluate, we can fall back on Newton's difference quotient and still get a result
        switch (y_1, y_2) {
        case (nil, nil): throw FNError.failedToEvaluateSlopeSamplePoints
        case (nil, _): (x_1, y_1) = (x, y)
        case (_, nil): (x_2, y_2) = (x, y)
        default: break
        }
        // Return
        let s = (y_2 - y_1) / (x_2 - x_1)
        if abs(s) < accuracy { return 0 } // Round if necessary
        return s
    }
}
