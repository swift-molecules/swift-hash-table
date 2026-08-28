import Affine_Standard_Library_Integration
public import Buffer_Linear_Primitive
import Buffer_Linear
public import Buffer
public import Cardinal
public import Hash
public import Hash_Table_Primitive
public import Index
public import Memory
public import Memory_Allocator_Primitive
public import Memory_Small
public import Ordinal
public import Storage
public import Storage_Memory
public import Tagged

extension __HashIndexed where Dense: ~Copyable {

    @inlinable
    public init<E: ~Copyable>(minimumCapacity: Tagged<E, Cardinal> = .zero)
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<E>>.Linear {
        self.init(
            elements: Dense(minimumCapacity: minimumCapacity),
            indices: Hash.Table(minimumCapacity: minimumCapacity)
        )
    }

    @inlinable
    @discardableResult
    public mutating func insert<E: ~Copyable>(_ element: consuming E) -> E?
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<E>>.Linear {
        let hashValue = element.hashValue
        let duplicate = indices.position(forHash: hashValue, context: element) {
            position,
            candidate in
            elements[position] == candidate
        }
        if case .some = duplicate {
            return element
        }
        let position = Index<E>(_unchecked: Ordinal(elements.count.underlying.rawValue))
        elements.append(element)
        indices.insert(_unchecked: (), position: position, hashValue: hashValue)
        return nil
    }

    @inlinable
    public mutating func remove<E: ~Copyable>(_ element: borrowing E) -> E?
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<E>>.Linear {
        guard let position = position(of: element) else { return nil }

        let storedHash = elements[position].hashValue
        let erased = indices.remove(hashValue: storedHash, context: position) { candidate, removed in
            candidate.underlying.rawValue == removed.underlying.rawValue
        }
        precondition(erased?.underlying.rawValue == position.underlying.rawValue)

        let removed = _removeShiftingDown(at: position)

        indices.positions.decrement(after: position)
        return removed
    }

    @inlinable
    public mutating func removeAll<E: ~Copyable>(keepingCapacity: Bool = true)
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<E>>.Linear {
        elements.removeAll(keepingCapacity: keepingCapacity)
        indices.remove.all(keepingCapacity: keepingCapacity)
    }

    @inlinable
    public func forEach(_ body: (borrowing Dense.Element) -> Void) {
        var raw: UInt = 0
        let end = indices.count.underlying.rawValue
        while raw < end {
            let slot = Index<Dense.Element>(_unchecked: Ordinal(raw))
            body(elements[slot])
            raw &+= 1
        }
    }
}

extension __HashIndexed where Dense: ~Copyable {

    @inlinable
    public func clone<E>() -> Self
    where
        Dense == Buffer<Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<E>>.Linear,
        E: Copyable
    {
        var copy = Self(minimumCapacity: .zero)
        copy.elements = elements.clone()
        copy.indices = indices.clone()
        return copy
    }
}

extension __HashIndexed where Dense: ~Copyable {

    @inlinable
    public func position<E: ~Copyable, Context: ~Copyable>(
        matching hashValue: Hash.Value,
        context: borrowing Context,
        equals: (borrowing E, borrowing Context) -> Bool
    ) -> Index<E>?
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<E>>.Linear {
        indices.position(forHash: hashValue, context: context) { position, context in
            equals(elements[position], context)
        }
    }

    @inlinable
    public mutating func remove<E: ~Copyable, Context: ~Copyable>(
        matching hashValue: Hash.Value,
        context: borrowing Context,
        equals: (borrowing E, borrowing Context) -> Bool
    ) -> E?
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<E>>.Linear {
        guard let position = position(matching: hashValue, context: context, equals: equals) else {
            return nil
        }

        let storedHash = elements[position].hashValue
        let erased = indices.remove(hashValue: storedHash, context: position) { candidate, removed in
            candidate.underlying.rawValue == removed.underlying.rawValue
        }
        precondition(erased?.underlying.rawValue == position.underlying.rawValue)

        let removed = _removeShiftingDown(at: position)

        indices.positions.decrement(after: position)
        return removed
    }
}

extension __HashIndexed where Dense: ~Copyable {

    @inlinable
    package mutating func _removeShiftingDown<E: ~Copyable>(at position: Index<E>) -> E
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<E>>.Linear {

        var frontier = elements.count.underlying.rawValue &- 1
        var carry = elements.move(at: Index<E>(_unchecked: Ordinal(frontier)))
        while position.underlying.rawValue < frontier {
            frontier &-= 1
            let slot = Index<E>(_unchecked: Ordinal(frontier))
            swap(&carry, &elements[slot])
        }
        return carry
    }
}
