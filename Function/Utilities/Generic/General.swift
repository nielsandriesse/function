
/// Returns `f(x!)` if `x != nil`, or `nil` otherwise.
func given<T, U>(_ x: T?, _ f: (T) throws -> U) rethrows -> U? { return try x.map(f) }

/// Returns `f(x!)` if `x != nil`, or `nil` otherwise.
func given<T, U>(_ x: T?, _ f: (T) throws -> U?) rethrows -> U? { return try x.flatMap(f) }

/// Returns `f(x!, y!)` if `x != nil && y != nil`, or `nil` otherwise.
func given<T, U, V>(_ x: T?, _ y: U?, _ f: (T, U) throws -> V) rethrows -> V? {
    guard let x = x, let y = y else { return nil }
    return try f(x, y)
}

func abstract(function: StaticString = #function, file: StaticString = #file, line: UInt = #line) -> Never  {
    fatalError("Abstract method not implemented: \(function).", file: file, line: line)
}

func preconditionFailure<T>(_ message: @autoclosure () -> String = "", file: StaticString = #file, line: UInt = #line) -> T {
    preconditionFailure(message, file: file, line: line)
}

/// Does nothing, but is never inlined and thus evaluating its argument will never be optimized away.
///
/// Useful for forcing the instantiation of lazy properties like globals.
@inline(never)
func touch<Value>(_ value: Value) { /* Do nothing */ }

extension Sequence {

    /// Returns the result of calling the given combining closure with each element of this sequence and an accumulating value. Returns `nil` if `nextPartialResult` returns `nil` at any point.
    ///
    /// - Parameter initialResult: The initial accumulating value.
    /// - Parameter nextPartialResult: A closure that combines an accumulating value and an element of the sequence into a new accumulating value, to be used in the next call of the `nextPartialResult` closure or returned to the caller.
    func failableReduce<U>(_ initialResult: U, _ nextPartialResult: (U, Iterator.Element) throws -> U?) rethrows -> U? {
        var result = initialResult
        for element in self {
            guard let newResult = try nextPartialResult(result, element) else { return nil }
            result = newResult
        }
        return result
    }
}

extension Collection where Index : Comparable {

    /// Returns `self[index]` if `index` is a valid index, or `nil` otherwise.
    subscript(ifValid index: Index) -> Iterator.Element? {
        return (index >= startIndex && index < endIndex) ? self[index] : nil
    }
}

extension Dictionary {

    func mapKeys<T>(_ transform: (Key)->T) -> [T:Value] {
        var result = [T:Value](minimumCapacity: count)
        for (key, value) in self {
            let transformedKey = transform(key)
            if result[transformedKey] != nil { preconditionFailure("Duplicate after transforming.") }
            result[transformedKey] = value
        }
        return result
    }
}

extension Comparable {
    
    func constrained(to range: ClosedRange<Self>) -> Self {
        if self > range.upperBound { return range.upperBound }
        if self < range.lowerBound { return range.lowerBound }
        return self
    }

    func constrained(toMin min: Self) -> Self {
        if self < min { return min }
        return self
    }

    func constrained(toMax max: Self) -> Self {
        if self > max { return max }
        return self
    }

    mutating func constrain(to range: ClosedRange<Self>) { self = self.constrained(to: range) }
    mutating func constrain(toMin min: Self) { self = self.constrained(toMin: min) }
    mutating func constrain(toMax max: Self) { self = self.constrained(toMax: max) }
}
