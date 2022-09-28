//
//  File.swift
//  
//
//  Created by Kulics Wu on 2022/9/30.
//

import Foundation

public final class HashMap<Key, Value>: SwiftyCollection, ExpressibleByDictionaryLiteral where Key: Hashable {
    public typealias Element = (Key, Value)
    public typealias Iterator = HashMapIterator<Key, Value>
    
    var data: Dictionary<Key, Value>
    var modCount: Int
    
    public init() {
        self.data = [:]
        self.modCount = 0
    }
    
    public init<S>(of collection: S) where S: Collection, S.Element == Element {
        self.data = Dictionary<Key, Value>(uniqueKeysWithValues: collection)
        self.modCount = 0
    }
    
    public init(dictionaryLiteral elements: (Key, Value)...) {
        self.data = Dictionary(uniqueKeysWithValues: elements)
        self.modCount = 0
    }
    
    private init(clone: Dictionary<Key, Value>) {
        self.data = clone
        self.modCount = 0
    }
    
    public func makeIterator() -> HashMapIterator<Key, Value> {
        return HashMapIterator(source: self)
    }
    
    public var count: Int {
        return self.data.count
    }
    
    public subscript(index: Key) -> Value {
        get {
            return self.data[index]!
        }
        set(newValue) {
            self.data[index] = newValue
            self.modCount += 1
        }
    }
    
    public func contains(key: Key)-> Bool {
        return self.data[key] != nil
    }
    
    public func get(index: Key) -> Value? {
        return self.data[index]
    }
    
    public func put(key: Key, value: Value)-> Value? {
        let v = self.data.updateValue(value, forKey: key)
        self.modCount += 1
        return v
    }
    
    public func putAll<S>(contentsOf newElements: S) where S: Collection, Element == S.Element {
        for i in newElements {
            self[i.0] = i.1
            self.modCount += 1
        }
    }
    
    public func remove(key: Key)-> Value? {
        let v = self.data.removeValue(forKey: key)
        self.modCount += 1
        return v
    }
    
    public func find(where predicate: (Element)-> Bool)-> Element? {
        return self.data.first(where: predicate)
    }
    
    public func clear() {
        self.data.removeAll(keepingCapacity: true)
        self.modCount += 1
    }
    
    public func clone()-> HashMap<Key, Value> {
        return Self.init(clone: self.data)
    }
}

public struct HashMapIterator<Key, Value>: IteratorProtocol where Key: Hashable {
    public typealias Element = (Key, Value)
    
    let source: HashMap<Key, Value>
    var iterator: Dictionary<Key, Value>.Iterator
    var modCount: Int
    
    init(source: HashMap<Key, Value>) {
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

extension HashMap: Equatable where Value: Equatable {
    public static func == (lhs: HashMap<Key, Value>, rhs: HashMap<Key, Value>) -> Bool {
        return lhs.data == rhs.data
    }
    
    public static func != (lhs: HashMap<Key, Value>, rhs: HashMap<Key, Value>) -> Bool {
        return !(lhs.data == rhs.data)
    }
}

extension HashMap: CustomStringConvertible {
    public var description: String {
        return self.data.description
    }
}
