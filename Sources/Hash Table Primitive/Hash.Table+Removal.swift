import Affine_Standard_Library_Integration
public import Buffer_Primitive
public import Buffer_Slots_Primitive
import Buffer_Slots
import Cardinal
public import Cyclic_Index
import Hash
public import Index
public import Memory_Allocator_Primitive
public import Memory_Heap
internal import Ordinal
public import Ordinal_Standard_Library_Integration
internal import Property
public import Storage_Contiguous
public import Storage_Primitive
public import Store_Primitive
public import Store_Split

extension Hash.Table.Remove where Element: ~Copyable {

    public typealias View = Property<Hash.Table<Element>.Remove, Hash.Table<Element>>.Inout.Typed<
        Element
    >
}

extension Hash.Table where Element: ~Copyable {

    @inlinable
    package func _distance(from: Bucket.Index, to: Bucket.Index) -> UInt {
        let mask = UInt(bitPattern: Int(bitPattern: bucketCapacity)) &- 1
        let rawTo = UInt(bitPattern: Int(bitPattern: to))
        let rawFrom = UInt(bitPattern: Int(bitPattern: from))
        return (rawTo &- rawFrom) & mask
    }

    @inlinable
    package mutating func _shiftChain(into emptied: Bucket.Index) {
        var hole = emptied
        var current = Bucket.Index.Modular.successor(of: hole, capacity: bucketCapacity)
        while self[hash: current] != Self.empty {
            let ideal = Self.bucket(for: self[hash: current], seed: _seed, capacity: bucketCapacity)

            if _distance(from: ideal, to: hole) < _distance(from: ideal, to: current) {
                self[hash: hole] = self[hash: current]
                self[position: hole] = self[position: current]
                self[bucketOfRank: self[position: hole]] = hole
                self[hash: current] = Self.empty
                hole = current
            }
            current = Bucket.Index.Modular.successor(of: current, capacity: bucketCapacity)
        }
    }

    @inlinable
    @discardableResult
    public mutating func remove(
        hashValue: Hash.Value,
        equals: (Index<Element>) -> Bool
    ) -> Index<Element>? {
        guard let index = index(forHash: hashValue, equals: equals) else {
            return nil
        }

        let position = self[position: index]
        self[hash: index] = Self.empty
        _count = _count.subtract.saturating(.one)
        _shiftChain(into: index)
        return position
    }

    @inlinable
    @discardableResult
    public mutating func remove<Context: ~Copyable>(
        hashValue: Hash.Value,
        context: borrowing Context,
        equals: (Index<Element>, borrowing Context) -> Bool
    ) -> Index<Element>? {
        let hash = Self.normalize(hashValue)
        let capacity = bucketCapacity
        var currentBucket = Self.bucket(for: hash, seed: _seed, capacity: capacity)
        var probes: Index<Bucket>.Count = .zero

        while probes < capacity {
            let storedHash = self[hash: currentBucket]

            if storedHash == Self.empty {
                return nil
            }

            if storedHash == hash {
                let position = self[position: currentBucket]
                if equals(position, context) {
                    self[hash: currentBucket] = Self.empty
                    _count = _count.subtract.saturating(.one)
                    _shiftChain(into: currentBucket)
                    return position
                }
            }

            currentBucket = Bucket.Index.Modular.successor(of: currentBucket, capacity: capacity)
            probes += .one
        }

        return nil
    }

    @inlinable
    public mutating func remove(at bucketIdx: Bucket.Index) {
        precondition(self[hash: bucketIdx] != Self.empty)
        self[hash: bucketIdx] = Self.empty
        _count = _count.subtract.saturating(.one)
        _shiftChain(into: bucketIdx)
    }

    @inlinable
    public var remove: Remove.View {
        mutating _read {
            yield.init(&self)
        }
        mutating _modify {
            var view: Remove.View = .init(&self)
            yield &view
        }
    }
}

extension Property.Inout.Typed
where Tag == Hash.Table<Element>.Remove, Base == Hash.Table<Element>, Element: ~Copyable {

    @inlinable
    public mutating func all(keepingCapacity: Bool = false) {
        if keepingCapacity {
            base.value._buffer.fill(metadata: Hash.Table<Element>.empty)
            base.value._buffer.fill(payload: 0)
            base.value._count = .zero

        } else {
            let hashCapacity = Hash.Table<Element>.bucketCapacity(for: .zero)
            var buffer = Buffer<
                Store.Split<
                    Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>,
                    Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>
                >
            >.Slots(
                capacity: hashCapacity.retag(Int.self),
                metadataInitial: Hash.Table<Element>.empty
            )
            buffer.fill(payload: 0)
            base.value._buffer = buffer
            base.value._rankToBucket = Hash.Table<Element>.makeRankPlane(
                bucketCapacity: hashCapacity
            )
            base.value._count = .zero
        }
    }
}
