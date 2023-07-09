import Foundation

public final class Lista<Value>: Sequence {
    final class Node<T> {
        fileprivate let value: T
        fileprivate var next: Node<T>?

        init(_ value: T, _ next: Node<T>?) {
            self.value = value
            self.next = next
        }
    }

    private var head: Node<Value>?
    private var tail: Node<Value>?

    public var count: Int

    public init(value: Value? = nil) {
        if let value {
            let newNode = Node(value, nil)
            head = newNode
            tail = newNode
            count = 1
        } else {
            head = nil
            tail = nil
            count = 0
        }
    }

    public func push(_ value: Value) {
        count += 1

        let newNode = Node(value, head)
        if tail == nil {
            tail = newNode
        }
        head = newNode
    }

    public func append(_ value: Value) {
        count += 1

        let newNode = Node(value, nil)
        if let t = tail {
            t.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
    }

    public func append(contentsOf collection: Lista<Value>) {
        if collection.count == 0 {
            return
        }

        count += collection.count

        if let t = tail {
            t.next = collection.head
        } else {
            head = collection.head
        }
        tail = collection.tail
    }

    public func pop() -> Value? {
        if let top = head {
            count -= 1
            head = top.next
            if count == 0 {
                tail = nil
            }
            return top.value
        } else {
            return nil
        }
    }

    public var first: Value? {
        head?.value
    }

    public var last: Value? {
        tail?.value
    }
    
    public func slowItem(at index: Int) -> Value? {
        guard index >= 0, index < count else {
            return nil
        }
        
        var current: Node<Value>? = head
        for _ in 0 ..< index {
            current = current?.next
        }
        return current?.value
    }
    
    public func slowInsert(_ value: Value, at index: Int) -> Bool {
        guard index >= 0 else {
            return false
        }
        
        if index == 0 { // insert at head
            head = Node(value, head)
            if tail == nil {
                tail = head
            }
            count += 1
            return true
        }

        guard var prev = head else {
            return false
        }
        
        var current = head
        var index = index
        
        while let c = current {
            if index == 0 {
                prev.next = Node(value, c)
                count += 1
                return true
            } else {
                index -= 1
            }

            prev = c
            current = c.next
        }
        
        if index == 0 { // insert at end
            let new = Node(value, nil)
            if let t = tail {
                t.next = new
                tail = new
            } else {
                tail = new
            }
            count += 1
            return true
        }

        return false
    }

    public func slowDropLast() -> Value? {
        let last = tail?.value
        slowRemove(at: count - 1)
        return last
    }

    @discardableResult
    public func slowRemove(at index: Int) -> Value? {
        guard var prev = head, index >= 0, count > 0 else {
            return nil
        }
        
        if index == 0 {
            let value = prev.value
            head = prev.next
            count -= 1
            return value
        }

        var current = head
        var index = index
        
        while let c = current {
            if index == 0 {
                prev.next = c.next
                count -= 1
                if count == 0 {
                    head = nil
                    tail = nil
                } else if tail === c {
                    tail = prev
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

    @discardableResult
    public func remove(first removeCheck: (Value) -> Bool) -> Bool {
        guard var prev = head else {
            return false
        }

        var current = head

        while let c = current {
            if removeCheck(c.value) {
                prev.next = c.next
                count -= 1
                if count == 0 {
                    head = nil
                    tail = nil
                } else if tail === c {
                    tail = prev
                }
                return true
            }

            prev = c
            current = c.next
        }

        return false
    }

    public func removeAll(where removeCheck: (Value) -> Bool) {
        guard var prev = head else {
            return
        }

        var current = head

        while let c = current {
            if removeCheck(c.value) {
                prev.next = c.next
                count -= 1
                if count == 0 {
                    head = nil
                    tail = nil
                    return
                } else if tail === c {
                    tail = prev
                }
                current = c.next
            } else {
                prev = c
                current = c.next
            }
        }
    }

    public func removeAll() {
        head = nil
        tail = nil
        count = 0
    }

    public final class ListaIterator: IteratorProtocol {
        private var current: Node<Value>?

        fileprivate init(_ current: Node<Value>?) {
            self.current = current
        }

        public func next() -> Value? {
            if let res = current {
                current = res.next
                return res.value
            } else {
                return nil
            }
        }
    }

    public func makeIterator() -> ListaIterator {
        ListaIterator(head)
    }
}

extension Lista: Codable where Value: Codable {
    public convenience init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        self.init()
        while !container.isAtEnd {
            let element = try container.decode(Value.self)
            append(element)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(contentsOf: self)
    }
}

public extension Lista where Value: AnyObject {
    @discardableResult
    func removeInstance(of item: Value) -> Bool {
        guard var prev = head else {
            return false
        }

        var current = head

        while let c = current {
            if c.value === item {
                prev.next = c.next
                count -= 1
                if count == 0 {
                    head = nil
                    tail = nil
                } else if tail === c {
                    tail = prev
                }
                return true
            }

            prev = c
            current = c.next
        }

        return false
    }
}

