
enum FNError : Swift.Error {
    // General expression evaluation
    case missingVariable, divisionByZero, negativeRoot, trigonometricDomain, logarithmicDomain
    // Numerical algorithms
    case multivariateFunction, failedToEvaluateSlopeSamplePoints, missingInitialValues, invalidSearchInterval, invalidNumberOfSteps, maximumPrecisionExceeded
}
