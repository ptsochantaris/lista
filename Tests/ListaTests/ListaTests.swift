@testable import Lista
import XCTest

final class listaTests: XCTestCase {
    func testSendability() async {
        let list1 = Lista<Int>()
        let list2 = Lista<Int>()
        let list3 = Lista<Int>()
        await withTaskGroup(of: Void.self) { group in
            for i in 0 ..< 10000 {
                group.addTask {
                    list1.append(i)
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 1 ... 10) * NSEC_PER_MSEC)
                    list2.append(i)
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 1 ... 10) * NSEC_PER_MSEC)
                    list3.append(i)
                    try? await Task.sleep(nanoseconds: UInt64.random(in: 1 ... 10) * NSEC_PER_MSEC)
                }
            }
        }
        XCTAssertEqual(list1.count, 10000)
        XCTAssertEqual(list2.count, 10000)
        XCTAssertEqual(list3.count, 10000)
    }

    func testInitAppendAndIterating() {
        let list = Lista(value: 0)
        let originalList = stride(from: 1, to: 100, by: 1)
        for i in originalList {
            list.append(i)
        }
        XCTAssert(list.count == 100)
        XCTAssert(list.first == 0)
        XCTAssert(list.last == 99)

        let extra = Lista<Int>()
        extra.append(100)
        extra.append(101)
        extra.append(102)
        list.append(contentsOf: extra)
        XCTAssert(list.count == 103)
        XCTAssert(list.first == 0)
        XCTAssert(list.last == 102)

        list.append(from: [103, 104, 105])
        XCTAssert(list.count == 106)
        XCTAssert(list.first == 0)
        XCTAssert(list.last == 105)

        let doubled = list.map { $0 * 2 }
        XCTAssert(doubled.count == list.count)
        for i in 0 ..< list.count {
            guard let original = list.slowItem(at: i) else {
                XCTFail()
                return
            }
            XCTAssert(doubled[i] == original * 2)
        }
    }

    func testInitAndRemoval() {
        let list = Lista<Int>()
        for i in stride(from: 0, to: 200, by: 1) {
            list.append(i)
        }
        list.remove(first: { $0 == 5 })
        XCTAssert(list.count == 199)
        XCTAssert(!list.contains(5))

        list.remove(first: { $0 == 3 })
        XCTAssert(list.count == 198)
        XCTAssert(!list.contains(3))

        list.remove(first: { $0 == 123 })
        XCTAssert(list.count == 197)
        XCTAssert(!list.contains(123))

        list.remove(first: { $0 == 567 })
        XCTAssert(list.count == 197)
        XCTAssert(!list.contains(568))

        list.remove(first: { $0 == 199 })
        XCTAssert(list.last == 198)
        XCTAssert(list.count == 196)
        XCTAssert(!list.contains(199))

        list.removeAll(where: { [50, 51, 52, 85, 86, 87, 97, 98, 99, 197, 198, 345, 456].contains($0) })
        XCTAssert(list.contains(196))
        XCTAssert(!list.contains(197))
        XCTAssert(list.count == 185)

        XCTAssert(list.last == 196)
        XCTAssert(list.count == 185)

        XCTAssert(list.contains(0))
        XCTAssert(list.contains(96))
        XCTAssert(!list.contains(98))
        XCTAssert(!list.contains(52))
        XCTAssert(!list.contains(230))

        XCTAssert(list.slowRemove(at: 3) == 4)
        XCTAssert(!list.contains(4))
        XCTAssert(list.count == 184)

        XCTAssert(list.slowRemove(at: 3) == 6)
        XCTAssert(!list.contains(6))
        XCTAssert(list.count == 183)

        XCTAssert(list.slowRemove(at: -1) == nil)
        XCTAssert(list.first == 0)
        XCTAssert(list.slowRemove(at: 0) == 0)
        XCTAssert(list.first == 1)
        XCTAssert(list.slowRemove(at: 0) == 1)
        XCTAssert(list.first == 2)
        XCTAssert(list.slowRemove(at: 0) == 2)
        XCTAssert(list.count == 180)
        XCTAssert(list.slowRemove(at: 123) != nil)
        XCTAssert(list.slowRemove(at: 687) == nil)
        XCTAssert(list.count == 179)

        XCTAssert(list.last == 196)
        list.slowRemove(at: 139)
        XCTAssert(list.last == 196)
        XCTAssert(list.slowDropLast() == 196)
        XCTAssert(list.last == 195)
        XCTAssert(list.count == 177)

        list.removeAll()
        XCTAssert(list.count == 0)
        XCTAssert(list.first == nil)
        XCTAssert(list.last == nil)
    }

    func testPushAndPop() {
        let list = Lista<Int>()
        for i in stride(from: 0, to: 100, by: 1) {
            list.append(i)
        }
        XCTAssert(list.first == 0)
        list.push(300)
        XCTAssert(list.first == 300)
        XCTAssert(list.count == 101)
        XCTAssert(list.last == 99)

        list.push(301)
        XCTAssert(list.first == 301)
        XCTAssert(list.count == 102)
        XCTAssert(list.last == 99)

        list.push(302)
        XCTAssert(list.first == 302)
        XCTAssert(list.count == 103)
        XCTAssert(list.last == 99)

        XCTAssert(list.pop() == 302)
        XCTAssert(list.count == 102)
        XCTAssert(list.last == 99)

        XCTAssert(list.pop() == 301)
        XCTAssert(list.count == 101)
        XCTAssert(list.last == 99)

        XCTAssert(list.slowDropLast() == 99)
        XCTAssert(list.count == 100)
        XCTAssert(list.last == 98)

        XCTAssert(list.slowDropLast() == 98)
        XCTAssert(list.count == 99)
        XCTAssert(list.last == 97)

        list.push(400)
        XCTAssert(list.first == 400)
    }

    func testInsertionAndLookup() {
        let list = Lista<String>()
        XCTAssert(list.count == 0)

        XCTAssert(list.slowInsert("a", at: -1) == false)
        XCTAssert(list.count == 0)

        XCTAssert(list.slowInsert("b", at: 1) == false)
        XCTAssert(list.count == 0)

        XCTAssert(list.slowInsert("e", at: 10) == false)
        XCTAssert(list.count == 0)

        XCTAssert(list.slowInsert("f", at: 0) == true)
        XCTAssert(list.count == 1)
        XCTAssert(list.first == "f")
        XCTAssert(list.last == "f")

        XCTAssert(list.slowInsert("g", at: 10) == false)
        XCTAssert(list.count == 1)
        XCTAssert(list.first == "f")
        XCTAssert(list.last == "f")

        XCTAssert(list.slowInsert("h", at: 0) == true)
        XCTAssert(list.count == 2)
        XCTAssert(list.first == "h")
        XCTAssert(list.last == "f")

        XCTAssert(list.slowInsert("i", at: 10) == false)
        XCTAssert(list.count == 2)
        XCTAssert(list.first == "h")
        XCTAssert(list.last == "f")

        XCTAssert(list.slowInsert("j", at: 2) == true)
        XCTAssert(list.count == 3)
        XCTAssert(list.first == "h")
        XCTAssert(list.last == "j")

        XCTAssert(list.slowInsert("k", at: -1) == false)
        XCTAssert(list.count == 3)
        XCTAssert(list.first == "h")
        XCTAssert(list.last == "j")

        XCTAssert(list.slowInsert("l", at: 10) == false)
        XCTAssert(list.count == 3)
        XCTAssert(list.first == "h")
        XCTAssert(list.last == "j")

        XCTAssert(list.slowItem(at: -1) == nil)
        XCTAssert(list.slowItem(at: 0) == "h")
        XCTAssert(list.slowItem(at: 1) == "f")
        XCTAssert(list.slowItem(at: 2) == "j")
        XCTAssert(list.slowItem(at: 3) == nil)

        XCTAssert(list.filter { $0 != "f" } == ["h", "j"])
    }

    func testAppendPerformance() {
        measure {
            let list = Lista<Int>()
            for i in 0 ..< 100_000 {
                list.append(i)
            }
        }
    }
}
