<img src="https://ptsochantaris.github.io/trailer/ListaLogo.webp" alt="Logo" width=256 style="float: right; padding: 20pt">

# Lista

_This is my linked list. There are many like it, but this one is mine, in Swift._

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fptsochantaris%2Flista%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/ptsochantaris/lista) [![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fptsochantaris%2Flista%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/ptsochantaris/lista)

I keep finding myself reaching for a linked list structure on various occasions and either have to roll my own or import some large (and usually brilliant) package of multiple algorithms and storage types. I just want a tiny and fast linked list with no dependencies, so I ended up writing this one, and since I ended up using it in various places, I've made it available here for others to use/copy/tweak/improve.

Detailed docs [can be found here](https://swiftpackageindex.com/ptsochantaris/key-vine/documentation)

### Usage
Lista is a generic-typed Swift `Collection` implemented as a simple signle-linked list and conforming to `Codable` for serialising and deserialising. It has the expected performance characteristics. I find it most useful when implementing stacks and FIFO chains, as well as using it when an unknown (but generally large) number of items needs to be appended serially to a list. See the API section below for all the convenience methods provided.
```
let list = Lista<Int>()

list.append(1) // 1
list.append(contentsOf: [2, 3, 4]) // 1,2,3,4
print(list.last!) // 4

let popped = list.pop() // 2,3,4
print(popped!) // 1
print(list.first!) // 2

list.push(1) // 1,2,3,4
list.push(0) // 0,1,2,3,4
print(list.first!) // 0
print(list.count) // 5

let doubled = list.map { $0 * 2 }
print(doubled) // 0,2,4,6,8
```

### API
```
// Create, count items, get first or last items, if they exist
init(value: Value? = nil)
var count: Int
var first: Value?
var last: Value?

// Push and pop from the start of the list
func push(_ value: Value)
func pop() -> Value?

// Adding an element to the end of the list
func append(_ value: Value)

// Link another Lista to the end of this. Very fast.
func append(contentsOf collection: Lista<Value>)

// Append each element to the current list. Linear time.
func append<S: Sequence>(from sequence: S) where S.Iterator.Element == Value

// Removing elements. The first method is fast, the others require linear time.
func removeAll()
func remove(first removeCheck: (Value) -> Bool) -> Bool
func removeAll(where removeCheck: (Value) -> Bool)
```

The methods below allow random access, but, as their name suggests, are slow. If you find that you use them a lot, a linked list may not be the right solution :)
```
// Item at `index`
func slowItem(at index: Int) -> Value?

// Insert item at `index`, returns if it was inserted
func slowInsert(_ value: Value, at index: Int) -> Bool

// Remove item at `index`, returns the item that was removed
func slowRemove(at index: Int) -> Value?

// Remove item at the end - shorthand for `list.slowRemove(at: list.count - 1)`
func slowDropLast() -> Value?
```

If the `Value` type is `Codable` then Lista will conditionally conform to that as well, so it can be serialised and deserialised easily.
```
extension Lista: Codable where Value: Codable
```

If the `Value` type is an object, a performance-specific method allows the item to be detected by internally using a reference comparison instead of the equality operator.
```
func removeInstance(of item: Value) -> Bool
```

For public projects, I've used Lista in:
- [Trailer](https://github.com/ptsochantaris/trailer)
- [Trailer-CLI](https://github.com/ptsochantaris/trailer-cli)
- [trailer-ql](https://github.com/ptsochantaris/trailer-cli)
- [Gladys](https://github.com/ptsochantaris/gladys)

### License
Copyright (c) 2023 Paul Tsochantaris. Licensed under the MIT License, see LICENSE for details.
