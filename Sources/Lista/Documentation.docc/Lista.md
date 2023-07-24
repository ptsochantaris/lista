# ``Lista``

A focused, tested, and flexible linked-list implementation

## Overview

_This is my linked list. There are many like it, but this one is mine ...in Swift._

I keep finding myself reaching for a linked list structure on various occasions and either have to roll my own or import some large (and usually brilliant) package of multiple algorithms and storage types.

I just want a tiny and fast linked list with no dependencies, so I ended up writing this one, and since I ended up using it in various places, I've made it available here for others to use/copy/tweak/improve.

Lista is a generic-typed Swift `Sequence` implemented as a simple signle-linked list and conforming to `Codable` for serialising and deserialising. It has the expected performance characteristics. I find it most useful when implementing stacks and FIFO chains, as well as using it when an unknown (but generally large) number of items needs to be appended serially to a list.

## Topics

### Creating A List
- ``Lista/Lista/init(value:)``

### Inspecting
- ``Lista/Lista/count``
- ``Lista/Lista/first``
- ``Lista/Lista/last``


### Operations At The Start
- ``Lista/Lista/push(_:)``
- ``Lista/Lista/pop()``

### Operations At The End
- ``Lista/Lista/append(_:)``
- ``Lista/Lista/append(from:)``
- ``Lista/Lista/append(contentsOf:)``

### Removing
- ``Lista/Lista/removeAll()``
- ``Lista/Lista/removeAll(where:)``
- ``Lista/Lista/remove(first:)``
- ``Lista/Lista/removeInstance(of:)``

### Slower Random Access
- ``Lista/Lista/slowItem(at:)``
- ``Lista/Lista/slowRemove(at:)``
- ``Lista/Lista/slowInsert(_:at:)``
- ``Lista/Lista/slowDropLast()``

