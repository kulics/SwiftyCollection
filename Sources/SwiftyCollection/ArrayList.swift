//
//  File.swift
//  
//
//  Created by Kulics Wu on 2022/9/28.
//

import Foundation

public final class ArrayList<Element>: SwiftyCollection, ExpressibleByArrayLiteral {
    public typealias ArrayLiteralElement = Element
    public typealias Element = Element
    public typealias Iterator = ArrayListIterator<Element>
    
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
        return ArrayListIterator(source: self)
    }
    
    public var count: Int {
        return self.data.count
    }
    
    public var startIndex: Int { 0 }
    public var endIndex: Int { self.data.endIndex }
    
    public func get(at index: Int) -> Element? {
        if index < 0 || index > self.count {
            return nil
        }
        return self.data[index]
    }
    
    public func set(_ newElement: Element, at index: Int)-> Element? {
        if index < 0 || index > self.count {
            return nil
        }
        let v = self.data[index]
        self.data[index] = newElement
        self.modCount += 1
        return v
    }
    
    public subscript(position: Int) -> Element {
        get {
            return self.data[position]
        }
        set(newValue) {
            self.data[position] = newValue
            self.modCount += 1
        }
    }
    
    public func append(_ newElement: Element) {
        self.data.append(newElement)
        self.modCount += 1
    }
    
    public func appendAll<S>(contentsOf newElements: S) where S: Collection, Element == S.Element {
        self.data.append(contentsOf: newElements)
        self.modCount += 1
    }
    
    public func prepend(_ newElement: Element) {
        self.data.insert(newElement, at: self.startIndex)
        self.modCount += 1
    }
    
    public func prependAll<S>(contentsOf newElements: S) where S: Collection, Element == S.Element {
        self.data.insert(contentsOf: newElements, at: self.startIndex)
        self.modCount += 1
    }
    
    public func insert(_ newElement: Element, at index: Int) {
        self.data.insert(newElement, at: index)
        self.modCount += 1
    }
    
    public func insertAll<S>(contentsOf newElements: S, at index: Int) where S: Collection, Element == S.Element {
        self.data.insert(contentsOf: newElements, at: index)
        self.modCount += 1
    }
    
    public func remove(at index: Int)-> Element? {
        if index < 0 || index > self.count {
            return nil
        }
        let element = self.data.remove(at: index)
        self.modCount += 1
        return element
    }
    
    public func removeRange(at range: Range<Int>) {
        self.data.removeSubrange(range)
        self.modCount += 1
    }
    
    public func contains(element: Element)-> Bool where Element: Equatable {
        return self.data.contains(element)
    }
    
    public func clone()-> ArrayList<Element> {
        return Self.init(clone: self.data)
    }
    
    public func clear() {
        self.data.removeAll(keepingCapacity: true)
        self.modCount += 1
    }
    
    public func reverse() {
        self.data.reverse()
        self.modCount += 1
    }
    
    public func sort(by compare: (Element, Element)-> Bool) {
        self.data.sort(by: compare)
        self.modCount += 1
    }
    
    public func findFirst(where predicate: (Element)-> Bool)-> Element? {
        return self.data.first(where: predicate)
    }
    
    public func findLast(where predicate: (Element)-> Bool)-> Element? {
        return self.data.last(where: predicate)
    }
    
    public func toArray()-> Array<Element> {
        return self.data
    }
}

public struct ArrayListIterator<Element>: IteratorProtocol {
    public typealias Element = Element
    
    let source: ArrayList<Element>
    var iterator: Array<Element>.Iterator
    var modCount: Int
    
    init(source: ArrayList<Element>) {
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

extension ArrayList: Equatable where Element: Equatable {
    public static func == (lhs: ArrayList<Element>, rhs: ArrayList<Element>) -> Bool {
        return lhs.data == rhs.data
    }
    
    public static func != (lhs: ArrayList<Element>, rhs: ArrayList<Element>) -> Bool {
        return !(lhs.data == rhs.data)
    }
    
    public func findFirstIndex(of element: Element)-> Int? {
        return self.data.firstIndex(of: element)
    }
    
    public func findLastIndex(of element: Element)-> Int? {
        return self.data.lastIndex(of: element)
    }
}

extension ArrayList: CustomStringConvertible {
    public var description: String {
        return self.data.description
    }
}
