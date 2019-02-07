import Foundation

// MARK: - Extremum Type

enum ExtremumType { case minimum, maximum }



// MARK: - Steepest Gradient Method

extension FNFunction {

    /// Returns an approximation of a local extremum of `self`, as determined by the steepest gradient method.
    /// See [Wikipedia](https://en.wikipedia.org/wiki/Gradient_descent#Description) for more information.
    func approximateLocal(_ extremumType: ExtremumType, usingSteepestGradientMethodWithConfiguration configuration: SteepestGradientMethodConfiguration) throws -> (value: Double, coordinates: [String:Double])? {
        // Prepare
        var h = configuration.initialStepSize
        var p_n = configuration.startingPoint
        let accuracy = configuration.accuracy
        let variables = expression.variables.map { $0.symbol }
        // Check preconditions
        guard !isConstant else { return nil }
        guard variables.allSatisfy({ p_n[$0] != nil }) else { throw FNError.missingInitialValues } // There must be an initial value for each variable
        // Convenience
        func approximateSlope(withRespectTo variable: String) throws -> Double {
            let x_n = p_n[variable]!
            let v_n = try evaluate(for: p_n)
            let ε = max(x_n.nextUp - x_n, v_n.nextUp - v_n)
            let h = sqrt(ε) // See http://en.wikipedia.org/wiki/Numerical_differentiation for more information on this
            let (x_1, x_2) = (x_n - h, x_n + h)
            var p_1 = p_n
            p_1[variable] = x_1
            var p_2 = p_n
            p_2[variable] = x_2
            return try self.approximateSlope(between: p_1, and: p_2, withAccuracy: accuracy)
        }
        // Approximate the nearest extremum numerically by repeatedly stepping in the direction where the gradient
        // is steepest until every first derivative of the function is less than or equal to the accuracy
        while try variables.contains(where: { abs(try approximateSlope(withRespectTo: $0)) > accuracy }) {
            // Compute update for p_n (update each component in a temporary variable before assigning the result to p_n)
            var p_u = p_n
            // Keep halving the step size until we find a step size that's sufficiently small so
            // that the update decreases/increases (depending on extremum) the function value
            loop: while true {
                for variable in variables {
                    switch extremumType {
                    case .minimum: p_u[variable] = try p_n[variable]! - h * approximateSlope(withRespectTo: variable)
                    case .maximum: p_u[variable] = try p_n[variable]! + h * approximateSlope(withRespectTo: variable)
                    }
                }
                switch extremumType {
                case .minimum: if try evaluate(for: p_u) < evaluate(for: p_n) { break loop }
                case .maximum: if try evaluate(for: p_u) > evaluate(for: p_n) { break loop }
                }
                h = h / 2
            }
            // Assign update to p_n
            p_n = p_u
        }
        // Return
        return (value: try evaluate(for: p_n), coordinates: p_n)
    }
}

struct SteepestGradientMethodConfiguration {
    let startingPoint: [String:Double]
    let initialStepSize: Double
    let accuracy: Double
}
