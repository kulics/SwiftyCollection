public protocol SwiftyCollection: Sequence {
    var count: Int { get }
    var isEmpty: Bool { get }
}

extension Array: SwiftyCollection {}
extension Set: SwiftyCollection {}
extension Dictionary: SwiftyCollection {}
extension String: SwiftyCollection {}