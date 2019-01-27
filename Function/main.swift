
let f_1 = FNFunction(fromString: "tan(x)")!
let slope = try f_1.approximateSlope(at: 1, withAccuracy: 1e-4)
print(slope)

let f_2 = FNFunction(fromString: "(x^2 + y - 11)^2 + (x + y^2 - 7)^2")!
let configuration = SteepestGradientMethodConfiguration(startingPoint: [ "x" : 0.5, "y" : 1 ], initialStepSize: 1e-2, accuracy: 1e-4)
let maximum = try f_2.approximateLocal(.maximum, usingSteepestGradientMethodWithConfiguration: configuration)!
print("\(maximum.value) @ \(maximum.coordinates)")

let f_3 = FNFunction(fromString: "x^2")!
let integral = try f_3.approximateIntegral(over: 0...2, withNumberOfSteps: 1000)
print(integral)

let f_4 = FNFunction(fromString: "sin(x) * cos(x)")!
let root = try f_4.approximateRoot(startingWithInitialGuess: 1.25, accuracy: 1e-4)!
print(root)
