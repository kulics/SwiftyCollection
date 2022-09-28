//
//  File.swift
//  
//
//  Created by Kulics Wu on 2022/9/28.
//

import Foundation

extension Sequence {
    public var stream: Stream<Element> {
        return SequenceStream(self.makeIterator())
    }
}

open class Stream<T>: Sequence, IteratorProtocol {
    public typealias Element = T
    public typealias Iterator = Stream<Element>
    
    public final func makeIterator() -> Iterator {
        return self
    }
    
    public func next() -> Element? {
        return nil
    }
}

extension Stream {
    public func map<U>(_ transform: @escaping (T)->U) -> Stream<U> {
        return MapStream(self, transform: transform)
    }
    
    public func filter(where predicate: @escaping (T)->Bool) -> Stream<T> {
        return FilterStream(self, where: predicate)
    }
    
    public func enumerate() -> Stream<(Int, T)> {
        return EnumerateStream(self)
    }
    
    public func flatten<U>()-> Stream<U> where Element: Sequence, Element.Element == U {
        return FlattenStream(self)
    }

    public func concat(to rhs: Stream<T>)-> Stream<T> {
        return ConcatStream(self, to: rhs)
    }
    
    public func step(by count: Int)-> Stream<T> {
        return StepStream(self, count: count)
    }
    
    public func skip(_ count: Int)-> Stream<T> {
        return SkipStream(self, count: count)
    }
    
    public func limit(_ count: Int)-> Stream<T> {
        return LimitStream(self, count: count)
    }
    
    public func zip<U>(other: Stream<U>)-> Stream<(T, U)> {
        return ZipStream(self, other)
    }
    
    public func unzip<A, B>()-> (ArrayList<A>, ArrayList<B>) where Element == (A, B) {
        let arrA: ArrayList<A> = []
        let arrB: ArrayList<B> = []
        for (a, b) in self {
            arrA.append(a)
            arrB.append(b)
        }
        return (arrA, arrB)
    }
    
    public func forEach(action: (Element)->Void) {
        for i in self {
            action(i)
        }
    }
    
    public func isEmpty()-> Bool {
        return self.makeIterator().next() == nil
    }
    
    public func count()-> Int {
        return self.fold(initial: 0) { v, _ in
            v + 1
        }
    }
    
    public func contains(_ element: Element)-> Bool where Element: Equatable {
        for i in self {
            if i == element {
                return true
            }
        }
        return false
    }
    
    public func sum()-> Element where Element: AdditiveArithmetic {
        return self.fold(initial: Element.zero) { a, b in
            a + b
        }
    }
    
    public func product()-> Element where Element: BinaryInteger {
        return self.fold(initial: 1) { a, b in
            a * b
        }
    }
    
    public func average()-> Element where Element: BinaryFloatingPoint {
        return self.enumerate().fold(initial: Element.zero) { result, pair in
            result + (pair.1 - result) / T(pair.0 + 1)
        }
    }
    
    public func max()-> Element? where Element: Comparable {
        return self.reduce { a, b in
            a > b ? a : b
        }
    }
    
    public func maxBy(_ greater: (Element, Element)-> Bool)-> Element? {
        return self.reduce { a, b in
            greater(a, b) ? a : b
        }
    }
    
    public func min()-> Element? where Element: Comparable {
        return self.reduce { a, b in
            a < b ? a : b
        }
    }
    
    public func minBy(_ less: (Element, Element)-> Bool)-> Element? {
        return self.reduce { a, b in
            less(a, b) ? a : b
        }
    }
    
    public func allMatch(_ predicate: (T)->Bool)-> Bool {
        for i in self {
            if !predicate(i) {
                return false
            }
        }
        return true
    }
    
    public func anyMatch(_ predicate: (T)->Bool)-> Bool {
        for i in self {
            if predicate(i) {
                return true
            }
        }
        return false
    }
    
    public func noneMatch(_ predicate: (T)->Bool)-> Bool {
        for i in self {
            if predicate(i) {
                return false
            }
        }
        return true
    }
    
    public func first()-> Element? {
        return self.next()
    }
    
    public func last()-> Element? {
        return self.fold(initial: nil) { _, next in
             next
        }
    }
    
    public func at(_ index: Int)-> Element? {
        var result = self.next()
        var i = 0
        while i < index && result != nil {
            result = self.next()
            i += 1
        }
        return result
    }
    
    @inlinable
    public func fold<R>(initial: R, operation: (R, T)-> R)-> R {
        var r = initial
        for i in self {
            r = operation(r, i)
        }
        return r
    }
    
    @inlinable
    public func reduce(operation: (T, T)-> T)-> T? {
        if let item = self.next() {
            return self.fold(initial: item, operation: operation)
        }
        return nil
    }
    
    public func collect<R: FromStream>()-> R where R.Element == Element {
        return R.fromStream(self)
    }
    
    public func collect<R: Collector>(by c: R)-> R.Finisher where Element == R.Element {
        let s = c.supply()
        for i in self {
            c.accumulate(supplier: s, element: i)
        }
        return c.finish(supplier: s)
    }
}

final class SequenceStream<I, T>: Stream<T> where I: IteratorProtocol, I.Element == T {
    var sourceIterator: I
    
    init(_ sourceIterator: I) {
        self.sourceIterator = sourceIterator
    }
    
    override func next() -> Element? {
        return self.sourceIterator.next()
    }
}

final class MapStream<T, U>: Stream<U> {
    let transform: (T)->U
    let sourceIterator: Stream<T>
    
    init(_ sourceIterator: Stream<T>, transform: @escaping (T)->U) {
        self.sourceIterator = sourceIterator
        self.transform = transform
    }
    
    override func next() -> Element? {
        return self.sourceIterator.next().map(self.transform)
    }
}

final class FilterStream<T>: Stream<T> {
    let predicate: (T)->Bool
    let sourceIterator: Stream<T>
    
    init(_ sourceIterator: Stream<T>, where predicate: @escaping (T)->Bool) {
        self.sourceIterator = sourceIterator
        self.predicate = predicate
    }
    
    override func next() -> Element? {
        while let item = self.sourceIterator.next() {
            if self.predicate(item) {
                return item
            }
        }
        return nil
    }
}

final class EnumerateStream<T>: Stream<(Int, T)> {
    var index: Int
    let sourceIterator: Stream<T>
    
    init(_ sourceIterator: Stream<T>) {
        self.sourceIterator = sourceIterator
        self.index = -1
    }
    
    override func next() -> Element? {
        if let item = self.sourceIterator.next() {
            index += 1
            return (index, item)
        }
        return nil
    }
}

final class FlattenStream<T, U>: Stream<U> where T: Sequence, T.Element == U {
    var subIterator: Stream<U>? = nil
    let sourceIterator: Stream<T>
    
    init(_ sourceIterator: Stream<T>) {
        self.sourceIterator = sourceIterator
    }
    
    override func next() -> U? {
        if let iter = self.subIterator {
            if let item = iter.next() {
                return item
            } else {
                self.subIterator = nil
                return self.next()
            }
        } else if let iter = self.sourceIterator.next() {
            self.subIterator = iter.stream
            return self.next()
        } else {
            return nil
        }
    }
}

final class ZipStream<T, U>: Stream<(T, U)> {
    let firstStream: Stream<T>
    let secondStream: Stream<U>
    
    init(_ firstStream: Stream<T>, _ secondStream: Stream<U>) {
        self.firstStream = firstStream
        self.secondStream = secondStream
    }
    
    override func next() -> (T, U)? {
        if case let (v1?, v2?) = (self.firstStream.next(), self.secondStream.next()) {
            return (v1, v2)
        }
        return nil
    }
}

final class ConcatStream<T>: Stream<T> {
    var firstNotFinished: Bool
    let firstStream: Stream<T>
    let lastStream: Stream<T>
    
    init(_ first: Stream<T>, to last: Stream<T>) {
        self.firstStream = first
        self.lastStream = last
        self.firstNotFinished = false
    }
    
    override func next() -> Element? {
        if self.firstNotFinished {
            if let item = self.firstStream.next() {
                return item
            }
            self.firstNotFinished = false
            return self.next()
        }
        return self.lastStream.next()
    }
}

final class StepStream<T>: Stream<T> {
    let countValue: Int
    var firstTake: Bool
    let sourceIterator: Stream<T>
    
    init(_ sourceIterator: Stream<T>, count: Int) {
        self.sourceIterator = sourceIterator
        self.firstTake = true
        self.countValue = count - 1
    }
    
    override func next() -> Element? {
        if self.firstTake {
            self.firstTake = false
            return self.sourceIterator.next()
        } else {
            return self.sourceIterator.at(self.countValue)
        }
    }
}

final class SkipStream<T>: Stream<T> {
    var countValue: Int
    let sourceIterator: Stream<T>
    
    init(_ sourceIterator: Stream<T>, count: Int) {
        self.sourceIterator = sourceIterator
        self.countValue = count
    }
    
    override func next() -> Element? {
        while self.countValue > 0 {
            if self.sourceIterator.next() == nil {
                return nil
            }
            self.countValue -= 1
        }
        return self.sourceIterator.next()
    }
}

final class LimitStream<T>: Stream<T> {
    var countValue: Int
    let sourceIterator: Stream<T>
    
    init(_ sourceIterator: Stream<T>, count: Int) {
        self.sourceIterator = sourceIterator
        self.countValue = count
    }
    
    override func next() -> Element? {
        if self.countValue != 0 {
            self.countValue -= 1
            return self.sourceIterator.next()
        }
        return nil
    }
}

public protocol FromStream {
    associatedtype Element
    static func fromStream(_ s: Stream<Element>)-> Self
}

extension Array: FromStream {
    public static func fromStream(_ s: Stream<Element>)-> Self {
        var result = Array<Element>()
        for i in s {
            result.append(i)
        }
        return result
    }
}

extension Set: FromStream {
    public static func fromStream(_ s: Stream<Element>)-> Self {
        var result = Set<Element>()
        for i in s {
            result.insert(i)
        }
        return result
    }
}

extension Dictionary: FromStream {
    public static func fromStream(_ s: Stream<Element>)-> Self {
        var result = [Key: Value]()
        for i in s {
            result[i.key] = i.value
        }
        return result
    }
}

extension ArrayList: FromStream {
    public static func fromStream(_ s: Stream<Element>)-> ArrayList<Element> {
        let result = ArrayList<Element>()
        for i in s {
            result.append(i)
        }
        return result
    }
}

public protocol Collector {
    associatedtype Element
    associatedtype Supplier
    associatedtype Finisher
    
    func supply()-> Supplier
    func accumulate(supplier: Supplier, element: Element)
    func finish(supplier: Supplier)-> Finisher
}
