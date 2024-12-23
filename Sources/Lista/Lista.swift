import Foundation

private final class Node<T> {
    let value: T
    var next: Node<T>?

    init(_ value: T, _ next: Node<T>?) {
        self.value = value
        self.next = next
    }
}

// An instance of a list
public final class Lista<Value>: Sendable {
    private nonisolated(unsafe) var _head: Node<Value>?
    private nonisolated(unsafe) var _tail: Node<Value>?
    private nonisolated(unsafe) var _count: Int

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS)
    private nonisolated(unsafe) var _lock = os_unfair_lock_s()

    @inline(__always)
    private func lock() {
        os_unfair_lock_lock(&_lock)
    }

    @inline(__always)
    private func unlock() {
        os_unfair_lock_unlock(&_lock)
    }
#else
    private let _lock = NSLock()

    @inline(__always)
    private func lock() {
        _lock.lock()
    }

    @inline(__always)
    private func unlock() {
        _lock.unlock()
    }
#endif

    /// The number of items currently in this list
    public var count: Int {
        lock()
        defer { unlock() }
        return _count
    }

    /// Create a new list
    /// - Parameter value: An optional item to start off the list with
    ///
    /// ```
    /// let list = Lista<Int>()  // An empty list that stores `Int`s
    /// ```
    /// ```
    /// let list = Lista(value: "First!") // A list containing a `String`
    /// ```
    public init(value: Value? = nil) {
        if let value {
            let newNode = Node(value, nil)
            _head = newNode
            _tail = newNode
            _count = 1
        } else {
            _head = nil
            _tail = nil
            _count = 0
        }
    }

    /// Add an item to the start of the list
    /// - Parameter value: The item to add
    ///
    /// ```
    /// let list = Lista(value: 1)  // [1]
    /// list.push(0)                // [0, 1]
    /// ```
    /// This is a fast, constant-time, operation.
    public func push(_ value: Value) {
        lock()
        defer { unlock() }

        _count += 1

        let newNode = Node(value, _head)
        if _tail == nil {
            _tail = newNode
        }
        _head = newNode
    }

    /// Remove and return (pop!) the item at the start of this list
    /// - Returns: The item that used to be the first item on the list, or `nil` if empty
    ///
    /// ```
    /// let list = Lista(value: 1)  // [2]
    /// list.push(1)                // [1, 2]
    /// list.push(0)                // [0, 1, 2]
    /// list.pop()                  // [1, 2]
    /// ```
    /// This is a fast, constant-time, operation.
    public func pop() -> Value? {
        lock()
        defer { unlock() }

        if let top = _head {
            _count -= 1
            _head = top.next
            if _count == 0 {
                _tail = nil
            }
            return top.value
        } else {
            return nil
        }
    }

    /// Add an item to the end of the list
    /// - Parameter value: The item to add
    ///
    /// ```
    /// let list = Lista(value: 1)  // [1]
    /// list.append(2)              // [1, 2]
    /// ```
    /// This is a fast, constant-time, operation.
    public func append(_ value: Value) {
        lock()
        defer { unlock() }

        _append(value)
    }

    private func _append(_ value: Value) {
        _count += 1

        let newNode = Node(value, nil)
        if let t = _tail {
            t.next = newNode
        } else {
            _head = newNode
        }
        _tail = newNode
    }

    /// Link another list to the end of this list
    /// - Parameter collection: The collection whose head will link to the tail of this list. *Note* that once this is performed, the added list is no longer usable and its reference should be discarded
    ///
    /// ```
    /// let list = Lista(value: 1)         // [1]
    /// list.append(2)                     // [1, 2]
    ///
    /// let otherList = Lista(value: 3)    // [3]
    /// otherList.append(4)                // [3, 4]
    ///
    /// list.append(contentsOf: otherList) // [1, 2, 3, 4]
    /// ```
    /// This is a fast, constant-time, operation.
    public func append(contentsOf collection: Lista<Value>) {
        lock()
        defer { unlock() }

        _append(contentsOf: collection)
    }

    private func _append(contentsOf collection: Lista<Value>) {
        if collection.count == 0 {
            return
        }

        _count += collection.count

        if let t = _tail {
            t.next = collection._head
        } else {
            _head = collection._head
        }
        _tail = collection._tail
    }

    /// Add all the items of the sequence to the end of this list
    /// - Parameter sequence: The sequence from which to read the items
    ///
    /// ```
    /// let list = Lista(value: 1)        // [1]
    /// let otherList: [Int] = [2, 3, 4]
    /// list.append(from: otherList)      // [1, 2, 3, 4]
    /// ```
    /// This is a fast, constant-time, operation.
    public func append<S: Sequence>(from sequence: S) where S.Iterator.Element == Value {
        lock()
        defer { unlock() }

        for item in sequence {
            _append(item)
        }
    }

    /// The  item at the start the list, if the list is not empty
    ///
    /// ```
    /// let list = Lista(value: 1)  // [1]
    /// list.push(0)                // [0, 1]
    /// print(list.first!)          // [0, 1] -> "0"
    /// ```
    /// This is a fast, constant-time, operation.
    public var first: Value? {
        lock()
        defer { unlock() }
        return _head?.value
    }

    /// The item at the end of the list, if the list is not empty
    ///
    /// ```
    /// let list = Lista(value: 1)  // [1]
    /// list.push(0)                // [0, 1]
    /// print(list.last!)           // [0, 1] -> "1"
    /// ```
    /// This is a fast, constant-time, operation.
    public var last: Value? {
        lock()
        defer { unlock() }
        return _tail?.value
    }

    /// Retrieve an item at a specific index on the list
    /// - Parameter index: The zero-based index of the item in the list that we want to retrieve
    /// - Returns: The item at the specified index, or `nil` if the index is out of range
    ///
    /// ```
    /// let list = Lista(value: "a")        // ["a"]
    /// list.append(from: ["b", "c", "d"])  // ["a", "b", "c", "d"]
    /// print(list.slowItem(at: 1)          // "b"
    /// print(list.slowItem(at: 8)          // nil
    /// ```
    /// This is a slow, linear-time, operation. Typically a scenario that requires regular random accesses is not well suited for a linked-list. If you find that you are using this method extensively then using an array, or similar random access collection, may make more sense.
    public func slowItem(at index: Int) -> Value? {
        lock()
        defer { unlock() }

        guard index >= 0, index < _count else {
            return nil
        }

        var current: Node<Value>? = _head
        for _ in 0 ..< index {
            current = current?.next
        }
        return current?.value
    }

    /// Insert an item into the specific index on the list
    /// - Parameters:
    ///   - value: The value to insert
    ///   - index: A zero-based index which will become the index of this item after being inserted
    /// - Returns: `true` if successful or `false` if the index was out of range
    ///
    /// ```
    /// let list = Lista(value: "a")        // ["a"]
    /// list.append(from: ["b", "c", "d"])  // ["a", "b", "c", "d"]
    /// list.slowInsert("b+", at: 1)        // ["a", "b+", "b", "c", "d"] -> true
    /// list.slowInsert("b+", at: 8)        // ["a", "b+", "b", "c", "d"] -> false
    /// ```
    /// This is a slow, linear-time, operation. Typically a scenario that requires regular random inserts is not well suited for a linked-list. If you find that you are using this method extensively then using an array, or similar random access collection, may make more sense.
    public func slowInsert(_ value: Value, at index: Int) -> Bool {
        lock()
        defer { unlock() }

        guard index >= 0 else {
            return false
        }

        if index == 0 { // insert at head
            _head = Node(value, _head)
            if _tail == nil {
                _tail = _head
            }
            _count += 1
            return true
        }

        guard var prev = _head else {
            return false
        }

        var current = _head
        var index = index

        while let c = current {
            if index == 0 {
                prev.next = Node(value, c)
                _count += 1
                return true
            } else {
                index -= 1
            }

            prev = c
            current = c.next
        }

        if index == 0 { // insert at end
            let new = Node(value, nil)
            if let t = _tail {
                t.next = new
                _tail = new
            } else {
                _tail = new
            }
            _count += 1
            return true
        }

        return false
    }

    /// Remove the last element from the list
    /// - Returns: The item which used to be the last on the list, or `nil` if the list was empty
    ///
    /// ```
    /// let list = Lista(value: "a")        // ["a"]
    /// list.append(from: ["b", "c", "d"])  // ["a", "b", "c", "d"]
    /// list.slowDropLast()                 // ["a", "b", "c"] -> "d"
    /// list.slowDropLast()                 // ["a", "b"] -> "c"
    /// ```
    /// This is a slow, linear-time, operation. Typically a scenario that requires regular additions and drops from the edge of a list should use ``push(_:)`` and ``pop()`` instead, which modify the start of the list in constant-time, and act like a stack.
    public func slowDropLast() -> Value? {
        lock()
        defer { unlock() }

        let last = _tail?.value
        _slowRemove(at: _count - 1)
        return last
    }

    /// Remove an item at a specific index, if it exists
    /// - Parameter index: The index from which to remove the item
    /// - Returns: The item that used to be at the specific index, if the index was inside the range of the existing items
    ///
    /// ```
    /// let list = Lista(value: "a")        // ["a"]
    /// list.append(from: ["b", "c", "d"])  // ["a", "b", "c", "d"]
    /// list.slowRemove(at: 1)              // ["a", "c", "d"]       -> "b"
    /// list.slowRemove(at: 1)              // ["a", "d"]            -> "c"
    /// list.slowRemove(at: 8)              // ["a", "d"]            -> nil
    /// ```
    /// This is a slow, linear-time, operation. Typically a scenario that requires regular random removals is not well suited for a linked-list. If you find that you are using this method extensively then using an array, or similar random access collection, may make more sense.
    @discardableResult
    public func slowRemove(at index: Int) -> Value? {
        lock()
        defer { unlock() }
        return _slowRemove(at: index)
    }

    @discardableResult
    private func _slowRemove(at index: Int) -> Value? {
        guard var prev = _head, index >= 0, _count > 0 else {
            return nil
        }

        if index == 0 {
            let value = prev.value
            _head = prev.next
            _count -= 1
            return value
        }

        var current = _head
        var index = index

        while let c = current {
            if index == 0 {
                prev.next = c.next
                _count -= 1
                if _count == 0 {
                    _head = nil
                    _tail = nil
                } else if _tail === c {
                    _tail = prev
                }
                return c.value
            } else {
                index -= 1
            }

            prev = c
            current = c.next
        }

        return nil
    }

    /// Remove the first item that meets a certain programmatic criterion
    /// - Parameter removeCheck: A block which takes an item and returns `true` or `false` depending on whether it has found the relevant item
    /// - Returns: `true` or `false` indicating whether the item was found and removed
    ///
    /// ```
    /// let list = Lista(value: "a")        // ["a"]
    /// list.append(from: ["b", "b", "a"])  // ["a", "b", "b", "a"]
    /// list.remove(first: { $0 == "b" })   // ["a", "b", "a"] -> true
    /// list.remove(first: { $0 == "c" })   // ["a", "b", "a"] -> false
    /// ```
    /// If you want to remove multiple items that match a criterion, then ``removeAll(where:)`` may be more convenient.
    ///
    /// This is a linear-time operation, with very similar performance to the equivalent array or collection methods.
    @discardableResult
    public func remove(first removeCheck: (Value) -> Bool) -> Bool {
        lock()
        defer { unlock() }

        guard var prev = _head else {
            return false
        }

        var current = _head

        while let c = current {
            if removeCheck(c.value) {
                prev.next = c.next
                _count -= 1
                if _count == 0 {
                    _head = nil
                    _tail = nil
                } else if _tail === c {
                    _tail = prev
                }
                return true
            }

            prev = c
            current = c.next
        }

        return false
    }

    /// Remove all items that meet a certain programmatic criterion
    /// - Parameter removeCheck: A block which takes an item and returns `true` or `false` depending on whether it has found a relevant item
    /// - Returns: `true` or `false` indicating whether any items were found and removed
    ///
    /// ```
    /// let list = Lista(value: "a")          // ["a"]
    /// list.append(from: ["b", "b", "a"])    // ["a", "b", "b", "a"]
    /// list.removeAll(where: { $0 == "b" })  // ["a", "a"] -> true
    /// list.removeAll(first: { $0 == "c" })  // ["a", "a"] -> false
    /// ```
    /// If you only want to remove a single item then ``remove(first:)`` may be more convenient and slightly faster.
    ///
    /// This is a linear-time operation, with very similar performance to the equivalent array or collection methods.
    public func removeAll(where removeCheck: (Value) -> Bool) {
        lock()
        defer { unlock() }

        guard var prev = _head else {
            return
        }

        var current = _head

        while let c = current {
            if removeCheck(c.value) {
                prev.next = c.next
                _count -= 1
                if _count == 0 {
                    _head = nil
                    _tail = nil
                    return
                } else if _tail === c {
                    _tail = prev
                }
                current = c.next
            } else {
                prev = c
                current = c.next
            }
        }
    }

    /// Remove all items from the list
    ///
    /// ```
    /// let list = Lista(value: "a")        // ["a"]
    /// list.append(from: ["b", "b", "a"])  // ["a", "b", "b", "a"]
    /// list.removeAll()                    // []
    /// ```
    /// This is a fast, constant-time, operation.
    public func removeAll() {
        lock()
        defer { unlock() }
        _head = nil
        _tail = nil
        _count = 0
    }
}

extension Lista: Codable where Value: Codable {
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init()
        while !container.isAtEnd {
            let element = try container.decode(Value.self)
            _append(element)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: self)
    }
}

public extension Lista where Value: AnyObject {
    /// Remove the first item which is at the provided item's memory address for faster search performance
    /// - Parameter item: An item of reference type
    /// - Returns: `true` or `false` indicating whether the item was found and removed
    ///
    /// ```
    /// let object1 = NSString("a")
    /// let object2 = NSString("b")
    /// let object3 = NSString("b")
    ///
    /// let list = Lista(value: object1)    // [@"a"]
    /// list.append(object2)                // [@"a", @"b"]
    /// list.append(object2)                // [@"a", @"b", @"b"]
    ///
    /// list.removeInstance(of: object2)    // [@"a", @"b"] -> true
    /// list.removeInstance(of: object3)    // [@"a", @"b"] -> false
    ///
    /// list.removeInstance(of: object2)    // [@"a"] -> true
    /// list.removeInstance(of: object2)    // [@"a"] -> false
    /// ```
    /// If you want to remove an item that matches a criterion instead, or an item that is not a reference type, then ``remove(first:)`` may be more convenient
    /// This is a linear-time operation, with very similar performance to the equivalent array or collection methods
    @discardableResult
    func removeInstance(of item: Value) -> Bool {
        lock()
        defer { unlock() }
        guard var prev = _head else {
            return false
        }

        var current = _head

        while let c = current {
            if c.value === item {
                prev.next = c.next
                _count -= 1
                if _count == 0 {
                    _head = nil
                    _tail = nil
                } else if _tail === c {
                    _tail = prev
                }
                return true
            }

            prev = c
            current = c.next
        }

        return false
    }
}

extension Lista: Collection {
    public func index(after i: Int) -> Int { i + 1 }

    public subscript(position: Int) -> Value { slowItem(at: position)! }

    public var startIndex: Int { 0 }

    public var endIndex: Int { count }

    /// The iterator helper class for ``Lista``
    public final class ListaIterator: IteratorProtocol {
        private var current: Node<Value>?

        fileprivate init(_ current: Node<Value>?) {
            self.current = current
        }

        /// The next value in the list
        public func next() -> Value? {
            if let res = current {
                current = res.next
                return res.value
            } else {
                return nil
            }
        }
    }

    /// Create an iterator for sequentially traversing this list
    public func makeIterator() -> ListaIterator {
        ListaIterator(_head)
    }
}
