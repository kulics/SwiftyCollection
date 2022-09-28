public protocol SwiftyCollection: Sequence {
    var count: Int { get }
    var isEmpty: Bool { get }
    
    func toArray()-> Array<Element>
}

extension SwiftyCollection {
    public var isEmpty: Bool {
        return self.count == 0
    }
    
    public func toArray()-> Array<Element> {
        var r = Array<Element>()
        for i in self {
            r.append(i)
        }
        return r
    }
}

