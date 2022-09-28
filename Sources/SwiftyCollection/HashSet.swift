//
//  File.swift
//  
//
//  Created by Kulics Wu on 2022/10/1.
//

import Foundation

public final class HashSet<Element: Hashable>: SwiftyCollection, ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Element
    public typealias Element = Element
    public typealias Iterator = HashSetIterator<Element>
    
    var data: Set<Element>
    var modCount: Int
    
    public init() {
        self.data = []
        self.modCount = 0
    }
    
    public init<S>(of collection: S) where S: Collection, S.Element == Element {
        self.data = Set(collection)
        self.modCount = 0
    }
    
    public init(arrayLiteral elements: Element...) {
        self.data = Set(elements)
        self.modCount = 0
    }
    
    private init(clone: Set<Element>) {
        self.data = clone
        self.modCount = 0
    }
    
    public func makeIterator() -> Iterator {
        return HashSetIterator(source: self)
    }
    
    public var count: Int {
        return self.data.count
    }
    
    public func contains(element: Element)-> Bool {
        return self.data.contains(element)
    }
    
    public func containsAll<S>(of collection: S)-> Bool where S: Collection, S.Element == Element {
        return self.data.isStrictSuperset(of: collection)
    }
    
    public func put(_ newElement: Element) {
        self.data.insert(newElement)
        self.modCount += 1
    }
    
    public func putAll<S>(contentsOf newElements: S) where S: Collection, Element == S.Element {
        self.data.formUnion(newElements)
        self.modCount += 1
    }
    
    public func remove(element: Element)-> Element? {
        return self.data.remove(element)
    }
    
    public func clone()-> HashSet<Element> {
        return Self.init(clone: self.data)
    }
    
    public func clear() {
        self.data.removeAll(keepingCapacity: true)
        self.modCount += 1
    }
    
    public func toArray()-> Array<Element> {
        return Array(self.data)
    }
}

public struct HashSetIterator<Element>: IteratorProtocol where Element: Hashable {
    public typealias Element = Element
    
    let source: HashSet<Element>
    var iterator: Set<Element>.Iterator
    var modCount: Int
    
    init(source: HashSet<Element>) {
        self.source = source
        self.iterator = source.data.makeIterator()
        self.modCount = source.modCount
    }
    
    public mutating func next() -> Element? {
        if self.modCount != self.source.modCount {
            fatalError("concurrent modification error")
        }
        return self.iterator.next()
    }
}
