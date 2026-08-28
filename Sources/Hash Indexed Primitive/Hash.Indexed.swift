public import Cardinal
public import Hash
public import Hash_Table_Primitive
public import struct Index.Index
public import Ordinal
public import Storage
public import Tagged

extension Hash {

    public typealias Indexed = __HashIndexed
}

@_documentation(visibility: public)
@frozen
public struct __HashIndexed<Dense: Store.`Protocol` & ~Copyable>: ~Copyable
where Dense.Element: Hash.Key {

    @usableFromInline
    package var elements: Dense

    @usableFromInline
    package var indices: Hash.Table<Dense.Element>

    @inlinable
    public init(elements: consuming Dense, indices: consuming Hash.Table<Dense.Element>) {
        precondition(indices.isEmpty, "Hash.Indexed requires an empty index engine at composition")
        self.elements = elements
        self.indices = indices
    }

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
            let oldHash = elements[slot].hashValue
            yield &elements[slot]
            let newHash = elements[slot].hashValue
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
        let hashValue = element.hashValue
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
        indices.remove(hashValue: element.hashValue, context: slot) { position, removed in
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
        indices.position(forHash: element.hashValue, context: element) { position, candidate in
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
