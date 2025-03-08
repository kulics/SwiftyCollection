public struct Queue<Element>: SwiftyCollection {
    public typealias Element = Element
    public typealias Iterator = QueueIterator<Element>
    
    var data: Array<Element>
    
    public init() {
        self.data = []
    }
    
    public func makeIterator() -> Iterator {
        return QueueIterator(source: self)
    }
    
    public var count: Int {
        return self.data.count
    }

    public var isEmpty: Bool {
        return self.data.isEmpty
    }
    
    public mutating func enqueue(_ newElement: Element) {
        self.data.append(newElement)
    }
    
    public mutating func dequeue()-> Element? {
        if self.data.isEmpty {
            return nil
        }
        return self.data.removeFirst()
    }
    
    public func peek() -> Element? {
        return self.data.first
    }
}

public struct QueueIterator<Element>: IteratorProtocol {
    public typealias Element = Element
    
    let source: Queue<Element>
    var index: Int
    
    init(source: Queue<Element>) {
        self.source = source
        self.index = 0
    }
    
    public mutating func next() -> Element? {
        if self.index < self.source.data.count {
            let element = self.source.data[self.index]
            self.index += 1
            return element
        }
        return nil
    }
}