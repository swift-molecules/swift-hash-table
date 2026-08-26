public import Buffer_Protocol
public import Hash
public import Hash_Table_Primitive
public import Index
import Ordinal_Standard_Library_Integration
public import Store_Protocol

extension Hash {

    public typealias Indexed = __HashIndexed
}

@_documentation(visibility: public)
@frozen
public struct __HashIndexed<Dense: Store.`Protocol` & Buffer.`Protocol` & ~Copyable>: ~Copyable
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
    public var capacity: Index.Index<Dense.Element>.Count { elements.capacity }

    @inlinable
    public subscript(slot: Index.Index<Dense.Element>) -> Dense.Element {
        _read {
            yield elements[slot]
        }
        _modify {
            let oldHash = elements[slot].hashValue
            yield &elements[slot]
            let newHash = elements[slot].hashValue
            if oldHash != newHash {
                indices.remove(hashValue: oldHash, context: slot) { position, mutated in
                    position == mutated
                }
                indices.insert(_unchecked: (), position: slot, hashValue: newHash)
            }
        }
    }

    @inlinable
    public mutating func initialize(
        at slot: Index.Index<Dense.Element>,
        to element: consuming Dense.Element
    ) {
        precondition(
            slot == elements.count.map(Ordinal.init),
            "indexed seam: initialize is lawful only at the back (slot == count)"
        )
        let hashValue = element.hashValue
        elements.initialize(at: slot, to: element)
        indices.insert(_unchecked: (), position: slot, hashValue: hashValue)
    }

    @inlinable
    public mutating func move(at slot: Index.Index<Dense.Element>) -> Dense.Element {
        let last: Index.Index<Dense.Element> =
            elements.count.subtract.saturating(.one).map(Ordinal.init)
        precondition(
            slot == last,
            "indexed seam: move is lawful only at the back (slot == count − 1)"
        )
        let element = elements.move(at: slot)
        indices.remove(hashValue: element.hashValue, context: slot) { position, removed in
            position == removed
        }
        return element
    }
}

extension __HashIndexed: Buffer.`Protocol` where Dense: ~Copyable {

    @inlinable
    public var count: Index.Index<Dense.Element>.Count { elements.count }
}
