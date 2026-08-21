import Affine_Primitives_Standard_Library_Integration
public import Buffer_Linear_Primitive
import Buffer_Linear_Primitives
public import Buffer_Primitive
import Hash_Primitives
public import Hash_Table_Primitive
public import Index_Primitives
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
public import Storage_Primitive

extension __HashIndexed where Dense: ~Copyable {

    @inlinable
    public init<E: ~Copyable>(minimumCapacity: Index<E>.Count = .zero)
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear {
        self.init(
            elements: Dense(minimumCapacity: minimumCapacity),
            indices: Hash.Table(minimumCapacity: minimumCapacity)
        )
    }

    @inlinable
    @discardableResult
    public mutating func insert<E: ~Copyable>(_ element: consuming E) -> E?
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear {
        let hashValue = element.hashValue
        let duplicate = indices.position(forHash: hashValue, context: element) {
            position,
            candidate in
            elements[position] == candidate
        }
        if duplicate != nil {
            return element
        }
        let position: Index<E> = elements.count.map(Ordinal.init)
        elements.append(element)
        indices.insert(_unchecked: (), position: position, hashValue: hashValue)
        return nil
    }

    @inlinable
    public func contains<E: ~Copyable>(_ element: borrowing E) -> Bool
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear {
        position(of: element) != nil
    }

    @inlinable
    public func position<E: ~Copyable>(of element: borrowing E) -> Index<E>?
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear {
        indices.position(forHash: element.hashValue, context: element) { position, candidate in
            elements[position] == candidate
        }
    }

    @inlinable
    public mutating func remove<E: ~Copyable>(_ element: borrowing E) -> E?
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear {
        guard let position = position(of: element) else { return nil }

        let storedHash = elements[position].hashValue
        indices.remove(hashValue: storedHash, context: position) { candidate, removed in
            candidate == removed
        }

        let removed = _removeShiftingDown(at: position)

        indices.positions.decrement(after: position)
        return removed
    }

    @inlinable
    public mutating func removeAll<E: ~Copyable>(keepingCapacity: Bool = true)
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear {
        elements.removeAll(keepingCapacity: keepingCapacity)
        indices.remove.all(keepingCapacity: keepingCapacity)
    }

    @inlinable
    public func forEach(_ body: (borrowing Dense.Element) -> Void) {
        var slot: Index<Dense.Element> = .zero
        let end = elements.count.map(Ordinal.init)
        while slot < end {
            body(elements[slot])
            slot = slot.successor.saturating()
        }
    }
}

extension __HashIndexed where Dense: ~Copyable {

    @inlinable
    public func clone<E>() -> Self
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear, E: Copyable
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
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear {
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
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear {
        guard let position = position(matching: hashValue, context: context, equals: equals) else {
            return nil
        }

        let storedHash = elements[position].hashValue
        indices.remove(hashValue: storedHash, context: position) { candidate, removed in
            candidate == removed
        }

        let removed = _removeShiftingDown(at: position)

        indices.positions.decrement(after: position)
        return removed
    }
}

extension __HashIndexed where Dense: ~Copyable {

    @inlinable
    package mutating func _removeShiftingDown<E: ~Copyable>(at position: Index<E>) -> E
    where Dense == Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear {

        var frontier: Index<E>.Count = elements.count.subtract.saturating(.one)
        var carry = elements.move(at: frontier.map(Ordinal.init))
        while position < frontier.map(Ordinal.init) {
            frontier = frontier.subtract.saturating(.one)
            let slot: Index<E> = frontier.map(Ordinal.init)
            swap(&carry, &elements[slot])
        }
        return carry
    }
}
