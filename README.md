## Function

A framework for representing and performing numerical operations on mathematical functions in Swift.

Creating a function:

```swift
let function = FNFunction(fromString: "(x^2 + y - 11)^2 + (x + y^2 - 7)^2")! // Himmelblau's function
```

Approximating the slope at a given point using the symmetric difference quotient (univariate functions only):

```swift
let function = FNFunction(fromString: "tan(x)")!
let slope = try function.approximateSlope(at: 1, withAccuracy: 1e-4)
print(slope)
```

Approximating a local extremum using the steepest gradient method (full support for multivariate functions):

```swift
let function = FNFunction(fromString: "(x^2 + y - 11)^2 + (x + y^2 - 7)^2")!
let configuration = SteepestGradientMethodConfiguration(startingPoint: [ "x" : 0.5, "y" : 1 ], initialStepSize: 1e-2, accuracy: 1e-4)
let maximum = try function.approximateLocal(.maximum, usingSteepestGradientMethodWithConfiguration: configuration)!
print("\(maximum.value) @ \(maximum.coordinates)")
```

Approximating the integral over an interval using the rectangle rule (univariate functions only):

```swift
let function = FNFunction(fromString: "x^2")!
let integral = try function.approximateIntegral(over: 0...2, withNumberOfSteps: 1000)
print(integral)
```

Approximating a root using the Newton-Raphson method (univariate functions only):

```swift
let function = FNFunction(fromString: "sin(x) * cos(x)")!
let root = try function.approximateRoot(startingWithInitialGuess: 1.25, accuracy: 1e-4)!
print(root)
```
