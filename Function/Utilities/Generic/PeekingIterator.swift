
struct PeekingIterator<T : IteratorProtocol> {
    private var iterator: T
    private var nextElement: T.Element?

    init(wrapping iterator: T) {
        self.iterator = iterator
    }

    @discardableResult
    mutating func next() -> T.Element? {
        let nextElement = peek()
        self.nextElement = nil
        return nextElement
    }

    mutating func peek() -> T.Element? {
        if nextElement == nil {
            nextElement = iterator.next()
        }
        return nextElement
    }
}
