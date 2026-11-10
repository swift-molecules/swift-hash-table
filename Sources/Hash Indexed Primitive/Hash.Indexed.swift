public import Cardinal
public import Hash_Table_Primitive
public import Index
public import Ordinal
import Ownership
import Storage
public import Store
public import Tagged

extension Hash {

    public typealias Indexed = __HashIndexed
}

@_documentation(visibility: public)
@frozen
public struct __HashIndexed<Dense: Store.`Protocol` & ~Copyable>: ~Copyable
where Dense.Element: Swift::Hashable {

    @usableFromInline
    package var elements: Dense

    @usableFromInline
    package var indices: Hash.Table<Dense.Element>

    /// Composes a column over `elements`, whose slots `0..<count` hold its members, and indexes them.
    @inlinable
    public init(elements: consuming Dense, count: Tagged<Dense.Element, Cardinal>) {
        precondition(
            count.underlying.rawValue <= elements.capacity.underlying.rawValue,
            "Hash.Indexed: count exceeds the dense store's capacity"
        )
        var indices = Hash.Table<Dense.Element>(minimumCapacity: elements.capacity)
        var raw: UInt = 0
        while raw < count.underlying.rawValue {
            let slot = Index<Dense.Element>(_unchecked: Ordinal(raw))
            let hashValue = Hash.Value(_unchecked: elements[slot].hashValue)
            let duplicate = indices.position(forHash: hashValue, context: slot) { position, member in
                elements[position] == elements[member]
            }
            precondition(duplicate == nil, "Hash.Indexed: the dense store holds a member twice")
            indices.insert(_unchecked: (), position: slot, hashValue: hashValue)
            raw &+= 1
        }
        self.elements = elements
        self.indices = indices
    }
}

extension __HashIndexed where Dense: ~Copyable {

    /// Composes a column from members and an index that already agree with each other.
    @inlinable
    package init(elements: consuming Dense, indices: consuming Hash.Table<Dense.Element>) {
        self.elements = elements
        self.indices = indices
    }
}

extension __HashIndexed where Dense: ~Copyable {
    @inlinable
    public consuming func take() -> Dense {
        elements
    }
}

extension __HashIndexed: Sendable where Dense: Sendable & ~Copyable, Dense.Element: Sendable {}

extension __HashIndexed: Store.`Protocol` where Dense: ~Copyable {

    public typealias Element = Dense.Element

    @inlinable
    public var capacity: Tagged<Dense.Element, Cardinal> { elements.capacity }

    @inlinable
    public subscript(slot: Index<Dense.Element>) -> Dense.Element {
        _read {
            yield elements[slot]
        }
        _modify {
            let oldHash = Hash.Value(_unchecked: elements[slot].hashValue)
            yield &elements[slot]
            let newHash = Hash.Value(_unchecked: elements[slot].hashValue)
            let duplicate = indices.position(forHash: newHash, context: slot) { position, written in
                position.underlying.rawValue != written.underlying.rawValue
                    && elements[position] == elements[written]
            }
            precondition(
                duplicate == nil,
                "Hash.Indexed: a subscript write must not make a member equal to another member"
            )
            if oldHash != newHash {
                indices.remove(hashValue: oldHash, context: slot) { position, mutated in
                    position.underlying.rawValue == mutated.underlying.rawValue
                }
                indices.insert(_unchecked: (), position: slot, hashValue: newHash)
            }
        }
    }

    @inlinable
    public mutating func initialize(
        at slot: Index<Dense.Element>,
        to element: consuming Dense.Element
    ) {
        precondition(
            slot.underlying.rawValue == indices.count.underlying.rawValue,
            "indexed seam: initialize is lawful only at the back (slot == count)"
        )
        let hashValue = Hash.Value(_unchecked: element.hashValue)
        elements.initialize(at: slot, to: element)
        indices.insert(_unchecked: (), position: slot, hashValue: hashValue)
    }

    @inlinable
    public mutating func move(at slot: Index<Dense.Element>) -> Dense.Element {
        let last = Index<Dense.Element>(
            _unchecked: Ordinal(indices.count.underlying.rawValue &- 1)
        )
        precondition(
            slot.underlying.rawValue == last.underlying.rawValue,
            "indexed seam: move is lawful only at the back (slot == count − 1)"
        )
        let element = elements.move(at: slot)
        indices.remove(hashValue: Hash.Value(_unchecked: element.hashValue), context: slot) { position, removed in
            position.underlying.rawValue == removed.underlying.rawValue
        }
        return element
    }
}

extension __HashIndexed where Dense: ~Copyable {

    @inlinable
    public var count: Tagged<Dense.Element, Cardinal> { indices.count }

    @inlinable
    public var isEmpty: Bool { indices.isEmpty }

    @inlinable
    public func position(of element: borrowing Dense.Element) -> Index<Dense.Element>? {
        indices.position(forHash: Hash.Value(_unchecked: element.hashValue), context: element) { position, candidate in
            elements[position] == candidate
        }
    }

    @inlinable
    public func contains(_ element: borrowing Dense.Element) -> Bool {
        if case .some = position(of: element) {
            return true
        }
        return false
    }

    @inlinable
    public mutating func removeAll() {
        var remaining = indices.count.underlying.rawValue
        while remaining > 0 {
            remaining &-= 1
            _ = elements.move(at: Index<Dense.Element>(_unchecked: Ordinal(remaining)))
        }
        indices.remove.all(keepingCapacity: true)
    }
}
