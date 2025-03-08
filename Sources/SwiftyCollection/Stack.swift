public struct Stack<Element>: SwiftyCollection {
    public typealias Element = Element
    public typealias Iterator = StackIterator<Element>
    
    var data: Array<Element>
    
    public init() {
        self.data = []
    }
    
    public func makeIterator() -> Iterator {
        return StackIterator<Element>(source: self)
    }
    
    public var count: Int {
        return self.data.count
    }

    public var isEmpty: Bool {
        return self.data.isEmpty
    }
    
    public mutating func push(_ newElement: Element) {
        self.data.append(newElement)
    }
    
    public mutating func pop()-> Element? {
        let element = self.data.popLast()
        return element
    }
    
    public func peek() -> Element? {
        return self.data.last
    }
}

public struct StackIterator<Element>: IteratorProtocol {
    public typealias Element = Element
    
    let source: Stack<Element>
    var index: Int
    
    init(source: Stack<Element>) {
        self.source = source
        self.index = source.data.count
    }
    
    public mutating func next() -> Element? {
        if self.index > 0 {
            self.index -= 1
            return self.source.data[self.index]
        }
        return nil
    }
}
