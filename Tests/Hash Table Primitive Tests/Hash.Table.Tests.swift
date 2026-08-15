import Buffer_Linear_Primitive
import Buffer_Primitive
import Buffer_Primitives_Test_Support
import Hash_Primitives
import Hash_Primitives_Standard_Library_Integration
import Hash_Table_Primitives
import Hash_Table_Primitives_Test_Support
import Index_Primitives
import Memory_Allocator_Primitive
import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
import Storage_Contiguous_Primitives
import Storage_Primitive
import Tagged_Primitives_Standard_Library_Integration
import Testing

// The reshaped engine (tombstone-free backward shift; per-instance seed) + the ordered
// hashed column. [DS-024] + the index-coherence laws run from this suite.

private typealias HeapStorage<E: ~Copyable> =
    Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>

private typealias DenseColumn<E: ~Copyable> = Buffer<HeapStorage<E>>.Linear
private typealias OrderedColumn<E: Hash.Key & ~Copyable> = Hash.Indexed<DenseColumn<E>>

/// Routes through the PROTOCOL's typed accessor (the stdlib `Int.hashValue` shadows it
/// in concrete contexts).
private func typedHash<T: Hash.`Protocol` & ~Copyable>(_ value: borrowing T) -> Hash.Value {
    value.hashValue
}

// MARK: - The engine: insert / lookup / remove with chain repair

@Suite
struct `Hash Table Engine Tests` {

    @Test
    func `insert, position, duplicate rejection`() {
        var table = Hash.Table<Int>(minimumCapacity: Index<Int>.Count(8))
        let inserted = table.insert(position: 0, hashValue: typedHash((42)), equals: { _ in false })
        #expect(inserted)
        let found = table.position(forHash: typedHash((42)), equals: { $0 == 0 })
        #expect(found == 0)
        let duplicate = table.insert(position: 1, hashValue: typedHash((42)), equals: { $0 == 0 })
        #expect(!duplicate)
        let n = table.count
        #expect(n == Index<Int>.Count(1))
    }

    @Test
    func `backward shift keeps collision chains findable after removal`() {
        var table = Hash.Table<Int>(minimumCapacity: Index<Int>.Count(8))
        // Three entries with the SAME hash → one probe chain.
        let h = typedHash((7))
        table.insert(position: 0, hashValue: h, equals: { _ in false })
        table.insert(position: 1, hashValue: h, equals: { _ in false })
        table.insert(position: 2, hashValue: h, equals: { _ in false })
        // Remove the chain HEAD; the shift must keep 1 and 2 findable.
        let removed = table.remove(hashValue: h, equals: { $0 == 0 })
        #expect(removed == 0)
        let p1 = table.position(forHash: h, equals: { $0 == 1 })
        let p2 = table.position(forHash: h, equals: { $0 == 2 })
        #expect(p1 == 1)
        #expect(p2 == 2)
        let n = table.count
        #expect(n == Index<Int>.Count(2))
        // Remove the middle of the remaining chain.
        _ = table.remove(hashValue: h, equals: { $0 == 1 })
        let p2b = table.position(forHash: h, equals: { $0 == 2 })
        #expect(p2b == 2)
    }

    @Test
    func `growth rehashes and re-seeds; entries stay findable`() {
        var table = Hash.Table<Int>(minimumCapacity: Index<Int>.Count(2))
        var i = 0
        while i < 64 {
            table.insert(
                position: Index<Int>(Ordinal(UInt(i))),
                hashValue: typedHash(i),
                equals: { _ in false }
            )
            i += 1
        }
        let n = table.count
        #expect(n == Index<Int>.Count(64))
        var missing = 0
        i = 0
        while i < 64 {
            let expected = Index<Int>(Ordinal(UInt(i)))
            if table.position(forHash: typedHash(i), equals: { $0 == expected }) != expected {
                missing += 1
            }
            i += 1
        }
        #expect(missing == 0)
    }

    @Test
    func `clone preserves seed and layout; the copies diverge independently`() {
        var table = Hash.Table<Int>(minimumCapacity: Index<Int>.Count(8))
        table.insert(position: 0, hashValue: typedHash((1)), equals: { _ in false })
        table.insert(position: 1, hashValue: typedHash((2)), equals: { _ in false })
        var copy = table.clone()
        let inBoth =
            (table.position(forHash: typedHash((1)), equals: { $0 == 0 }) == 0)
            && (copy.position(forHash: typedHash((1)), equals: { $0 == 0 }) == 0)
        #expect(inBoth)
        _ = copy.remove(hashValue: typedHash((1)), equals: { $0 == 0 })
        let stillInOriginal = table.position(forHash: typedHash((1)), equals: { $0 == 0 })
        #expect(stillInOriginal == 0)
        let goneInCopy = copy.position(forHash: typedHash((1)), equals: { $0 == 0 })
        #expect(goneInCopy == nil)
    }

    @Test
    func
        `a collision cluster wrapping the table end: backward shift repairs wrapped-edge, head, and middle removes`()
    {
        var table = Hash.Table<Int>(minimumCapacity: .zero)  // bucket capacity 8

        // Deterministic placement THROUGH the per-instance seed: bucket selection
        // is (hash ^ _seed) % capacity, so `_seed ^ 13` targets bucket 13 % 8 = 5
        // for ANY seed value. (13 and 21 are congruent mod 8; the fallback dodges
        // raw == 0, which normalize() would remap to 1 and move the cluster.)
        let seed = table._seed
        let raw = (seed ^ 13) != 0 ? (seed ^ 13) : (seed ^ 21)
        let h = Hash.Value(raw)

        // Five same-hash entries form ONE probe chain from bucket 5, WRAPPING the
        // table end: buckets 5, 6, 7, then 0, 1. (Five stays below the growth
        // gate: the pre-insert check is count·10 ≥ capacity·7, and 4·10 < 8·7.)
        for position in 0..<5 {
            let inserted = table.insert(
                position: Index<Int>(Ordinal(UInt(position))),
                hashValue: h,
                equals: { _ in false }
            )
            #expect(inserted)
        }
        expectWrappedCluster(table, from: 5, holding: [0, 1, 2, 3, 4], rawHash: raw)

        // 1 — remove AT THE WRAPPED EDGE (bucket 0): the tail entry at bucket 1
        //     must relocate backward INTO the wrapped hole.
        let atEdge = table.remove(hashValue: h, equals: { $0 == 3 })
        #expect(atEdge == 3)
        expectWrappedCluster(table, from: 5, holding: [0, 1, 2, 4], rawHash: raw)

        // 2 — remove the chain HEAD (bucket 5): every survivor shifts back one,
        //     and the wrapped entry crosses the table end BACKWARD (bucket 0 → 7).
        let atHead = table.remove(hashValue: h, equals: { $0 == 0 })
        #expect(atHead == 0)
        expectWrappedCluster(table, from: 5, holding: [1, 2, 4], rawHash: raw)

        // 3 — remove the chain MIDDLE (bucket 6).
        let atMiddle = table.remove(hashValue: h, equals: { $0 == 2 })
        #expect(atMiddle == 2)
        expectWrappedCluster(table, from: 5, holding: [1, 4], rawHash: raw)

        // The removed entries stay gone (no residue resurrects them).
        let ghostHead = table.position(forHash: h, equals: { $0 == 0 })
        let ghostEdge = table.position(forHash: h, equals: { $0 == 3 })
        #expect(ghostHead == nil)
        #expect(ghostEdge == nil)
    }
}

/// Asserts the single-ideal-chain invariant after backward-shift repair: the
/// occupied buckets are EXACTLY the cyclic run of `positions.count` buckets
/// from `start` (capacity 8), holding `positions` in insertion-relative order
/// (FCFS + backward shift preserve chain order); every other bucket is `empty`
/// (tombstone-free — no residue); every live bucket's rank back-pointer
/// round-trips (the coherence law-4 analog); every survivor is findable
/// through the public door.
private func expectWrappedCluster(
    _ table: borrowing Hash.Table<Int>,
    from start: Int,
    holding positions: [Int],
    rawHash: Int
) {
    let capacity = 8
    var expectedPosition: [Int: Int] = [:]  // bucket raw value → held position
    for (offset, position) in positions.enumerated() {
        expectedPosition[(start + offset) % capacity] = position
    }

    let count = table.count
    #expect(count == Index<Int>.Count(UInt(positions.count)))

    var bucket: Hash.Table<Int>.Bucket.Index = .zero
    let end = table.capacity.map(Ordinal.init)
    var bucketRaw = 0
    while bucket < end {
        let stored = table[hash: bucket]
        if let position = expectedPosition[bucketRaw] {
            // Occupied: our cluster's hash, the chain-order position, and a
            // round-tripping rank back-pointer (the B-7 plane under repair).
            #expect(stored == rawHash)
            let held = table[position: bucket]
            let expected = Index<Int>(Ordinal(UInt(position)))
            #expect(held == expected)
            let back = table[bucketOfRank: held]
            let backPointerRoundTrips = back == bucket
            #expect(backPointerRoundTrips)
        } else {
            #expect(stored == Hash.Table<Int>.empty)
        }
        bucket = bucket.successor.saturating()
        bucketRaw += 1
    }
    #expect(bucketRaw == capacity)  // the walk covered exactly the 8 buckets

    for position in positions {
        let expected = Index<Int>(Ordinal(UInt(position)))
        let found = table.position(forHash: Hash.Value(rawHash), equals: { $0 == expected })
        #expect(found == expected)
    }
}

// MARK: - The ordered hashed column: [DS-024] + coherence

@Suite
struct `Hash Indexed Law Tests` {

    @Test
    func `the ordered hashed column obeys the seam ledger laws`() {
        let violations = Seam.Ledger.violations(
            makeEmpty: { OrderedColumn<Int>(minimumCapacity: Index<Int>.Count(4)) },
            element: { $0 }
        )
        #expect(violations.isEmpty, "\(violations)")
    }

    @Test
    func `the index-coherence laws hold through inserts and removals`() {
        var column = OrderedColumn<Int>(minimumCapacity: Index<Int>.Count(4))
        var i = 0
        while i < 20 {
            column.insert(i * 7)
            i += 1
        }
        _ = column.remove(7 * 3)
        _ = column.remove(7 * 11)
        _ = column.remove(7 * 0)
        let violations = Hash.Coherence.violations(column)
        #expect(violations.isEmpty, "\(violations)")
    }
}

// MARK: - The ordered hashed column: behavior

@Suite(.serialized)
struct `Hash Indexed Tests` {

    @Test
    func `insert, contains, duplicate hand-back, counts`() {
        var column = OrderedColumn<Int>(minimumCapacity: Index<Int>.Count(4))
        let first = column.insert(10)
        #expect(first == nil)
        let dup = column.insert(10)
        #expect(dup == 10)  // move-only honesty: handed back
        column.insert(20)
        let has10 = column.contains(10)
        let has30 = column.contains(30)
        #expect(has10)
        #expect(!has30)
        let n = column.count
        #expect(n == Index<Int>.Count(2))
    }

    @Test
    func `removal preserves insertion order and stays coherent past growth`() {
        var column = OrderedColumn<Int>(minimumCapacity: Index<Int>.Count(2))
        var i = 0
        while i < 12 {
            column.insert(i)
            i += 1
        }
        let removed = column.remove(5)
        #expect(removed == 5)
        let absent = column.remove(5)
        #expect(absent == nil)
        var seen: [Int] = []
        column.forEach { seen.append($0) }
        #expect(seen == [0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11])  // dense order = insertion order
        let coherent = Hash.Coherence.violations(column)
        #expect(coherent.isEmpty, "\(coherent)")
    }

    /// Regression for the trailing-only seam trap.
    ///
    /// The removal dance used to open with an INTERIOR `elements.move(at: position)`, which
    /// violates `Buffer.Linear`'s trailing-only retraction contract. In `-Onone` that trips
    /// the buffer's `precondition`; in `-O` the same `precondition` lowers to
    /// `Builtin.condfail`, i.e. a bare `ud2` (SIGILL) with no diagnostic — the
    /// release-mode-only crash reported downstream. This is the exact reported sequence:
    /// 16 inserts, then `remove(9)` followed by `remove(0)`.
    @Test
    func `interior removal rides the seam lawfully: sixteen inserts, then remove 9 and remove 0`() {
        var column = OrderedColumn<Int>(minimumCapacity: Index<Int>.Count(4))
        var i = 0
        while i < 16 {
            column.insert(i)
            i += 1
        }
        let nine = column.remove(9)
        #expect(nine == 9)
        let zero = column.remove(0)
        #expect(zero == 0)
        var seen: [Int] = []
        column.forEach { seen.append($0) }
        #expect(seen == [1, 2, 3, 4, 5, 6, 7, 8, 10, 11, 12, 13, 14, 15])
        let n = column.count
        #expect(n == Index<Int>.Count(14))
        let violations = Hash.Coherence.violations(column)
        #expect(violations.isEmpty, "\(violations)")
        // The removed members are gone; every survivor is still findable.
        // (`contains` is bound to a local first: `#expect` on the call itself would
        // require the move-only column to be `Copyable`.)
        let hasNine = column.contains(9)
        let hasZero = column.contains(0)
        #expect(!hasNine)
        #expect(!hasZero)
        for survivor in seen {
            let found = column.contains(survivor)
            #expect(found, "survivor \(survivor) went missing")
        }
    }

    /// A denser sweep of the same law.
    ///
    /// Drains a 16-element column to empty under many different removal ORDERS (varying
    /// where the walk starts and how far it strides), checking insertion order and index
    /// coherence after every single removal. This covers head, interior, and trailing
    /// removals, and the final one-element column.
    @Test
    func `draining a sixteen-element column in any order preserves insertion order and coherence`()
    {
        var start = 0
        while start < 16 {
            var stride = 1
            while stride <= 5 {
                var column = OrderedColumn<Int>(minimumCapacity: Index<Int>.Count(4))
                var expected: [Int] = []
                var i = 0
                while i < 16 {
                    column.insert(i * 7)
                    expected.append(i * 7)
                    i += 1
                }
                var cursor = start
                while !expected.isEmpty {
                    let slot = cursor % expected.count
                    let victim = expected.remove(at: slot)
                    let removed = column.remove(victim)
                    #expect(removed == victim, "start \(start), stride \(stride), victim \(victim)")
                    var seen: [Int] = []
                    column.forEach { seen.append($0) }
                    #expect(seen == expected, "start \(start), stride \(stride), victim \(victim)")
                    let violations = Hash.Coherence.violations(column)
                    #expect(
                        violations.isEmpty,
                        "start \(start), stride \(stride), victim \(victim): \(violations)"
                    )
                    let stillThere = column.contains(victim)
                    #expect(!stillThere, "start \(start), stride \(stride), victim \(victim)")
                    cursor += stride
                }
                let empty = column.isEmpty
                #expect(empty)
                stride += 1
            }
            start += 1
        }
    }

    @Test
    func `removeAll empties both planes; reuse works`() {
        var column = OrderedColumn<Int>(minimumCapacity: Index<Int>.Count(4))
        column.insert(1)
        column.insert(2)
        column.removeAll()
        let isEmpty = column.isEmpty
        #expect(isEmpty)
        let gone = column.contains(1)
        #expect(!gone)
        column.insert(3)
        let has3 = column.contains(3)
        #expect(has3)
    }

    @Test
    func `clone detaches both planes`() {
        var column = OrderedColumn<Int>(minimumCapacity: Index<Int>.Count(4))
        column.insert(1)
        column.insert(2)
        var copy = column.clone()
        _ = copy.remove(1)
        let mineHas = column.contains(1)
        let theirsHas = copy.contains(1)
        #expect(mineHas)
        #expect(!theirsHas)
        let coherentMine = Hash.Coherence.violations(column)
        let coherentTheirs = Hash.Coherence.violations(copy)
        #expect(coherentMine.isEmpty && coherentTheirs.isEmpty)
    }
}

// MARK: - Move-only members end-to-end + teardown

@Suite(.serialized)
struct `Hash Indexed Teardown Tests` {

    @Test
    func `move-only members insert, resolve, remove, and tear down exactly once`() {
        HashProbe.reset()
        do {
            var column = OrderedColumn<HashItem>(minimumCapacity: Index<HashItem>.Count(4))
            column.insert(HashItem(1))
            column.insert(HashItem(2))
            column.insert(HashItem(3))
            let hasTwo = column.contains(HashItem(2))
            #expect(hasTwo)
            if let removed: HashItem = column.remove(HashItem(2)) {
                let id = removed.id
                #expect(id == 2)
            } else {
                Issue.record("expected the removed member")
            }
            let mid = HashProbe.destroyedSorted
            // The probe key Items (contains/remove arguments) + the removed member died.
            #expect(mid.contains(2))
        }
        let all = HashProbe.destroyedSorted
        let ones = all.filter { $0 == 1 }.count
        let threes = all.filter { $0 == 3 }.count
        #expect(ones == 1)  // each live member died exactly once
        #expect(threes == 1)
    }
}

private struct HashItem: ~Copyable {
    let id: Int
    init(_ id: Int) { self.id = id }
    deinit { HashProbe.recordDestroy(id) }
}

extension HashItem: Hash.`Protocol` {
    borrowing func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }

    static func == (lhs: borrowing HashItem, rhs: borrowing HashItem) -> Bool {
        lhs.id == rhs.id
    }
}

private enum HashProbe {}

extension HashProbe {
    nonisolated(unsafe) static var _destroyed: [Int] = []
    static func reset() { unsafe _destroyed = [] }
    static func recordDestroy(_ id: Int) { unsafe _destroyed.append(id) }
    static var destroyedSorted: [Int] { unsafe _destroyed.sorted() }
}
