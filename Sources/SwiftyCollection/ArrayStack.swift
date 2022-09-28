//
//  File.swift
//  
//
//  Created by Kulics Wu on 2022/10/1.
//

import Foundation

public final class ArrayStack<Element>: SwiftyCollection, ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Element
    public typealias Element = Element
    public typealias Iterator = ArrayStackIterator<Element>
    
    var data: Array<Element>
    var modCount: Int
    
    public init() {
        self.data = []
        self.modCount = 0
    }
    
    public init<S>(of collection: S) where S: Collection, S.Element == Element {
        self.data = Array(collection)
        self.modCount = 0
    }
    
    public init(arrayLiteral elements: Element...) {
        self.data = elements
        self.modCount = 0
    }
    
    private init(clone: Array<Element>) {
        self.data = clone
        self.modCount = 0
    }
    
    public func makeIterator() -> Iterator {
        return ArrayStackIterator(source: self)
    }
    
    public var count: Int {
        return self.data.count
    }
    
    public func push(_ newElement: Element) {
        self.data.append(newElement)
        self.modCount += 1
    }
    
    public func pushAll<S>(contentsOf newElements: S) where S: Collection, Element == S.Element {
        self.data.append(contentsOf: newElements)
        self.modCount += 1
    }
    
    public func pop()-> Element? {
        let element = self.data.popLast()
        self.modCount += 1
        return element
    }
    
    public func peek() -> Element? {
        return self.data.last
    }
    
    public func clone()-> ArrayStack<Element> {
        return Self.init(clone: self.data)
    }
    
    public func clear() {
        self.data.removeAll(keepingCapacity: true)
        self.modCount += 1
    }
    
    public func toArray()-> Array<Element> {
        return self.data
    }
}

public struct ArrayStackIterator<Element>: IteratorProtocol {
    public typealias Element = Element
    
    let source: ArrayStack<Element>
    var index: Int
    var modCount: Int
    
    init(source: ArrayStack<Element>) {
        self.source = source
        self.index = source.data.count
        self.modCount = source.modCount
    }
    
    public mutating func next() -> Element? {
        if self.modCount != self.source.modCount {
            fatalError("concurrent modification error")
        }
        if self.index > 0 {
            self.index -= 1
            return self.source.data[self.index]
        }
        return nil
    }
}
