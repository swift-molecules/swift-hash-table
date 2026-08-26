import Affine_Standard_Library_Integration
public import Buffer_Linear_Primitive
public import Buffer_Primitive
public import Buffer_Slots_Primitive
import Buffer_Slots
import Cardinal
public import Cyclic_Index
import Hash
public import Index
public import Memory_Allocator_Primitive
public import Memory_Heap
public import Ordinal_Standard_Library_Integration
public import Storage_Contiguous
public import Storage_Primitive
public import Store_Primitive
public import Store_Split

extension Hash.Table where Element: ~Copyable {

    @inlinable
    @discardableResult
    public mutating func insert(
        position: Index<Element>,
        hashValue: Hash.Value,
        equals: (Index<Element>) -> Bool
    ) -> Bool {
        if shouldGrow {
            grow()
        }

        let hash = Self.normalize(hashValue)
        var currentBucket = bucket.for(hash: hash)
        var probes: Index<Bucket>.Count = .zero
        let cap = bucketCapacity

        while probes < cap {
            let storedHash = self[hash: currentBucket]

            if storedHash == Self.empty {
                self[hash: currentBucket] = hash
                self[position: currentBucket] = position
                self[bucketOfRank: position] = currentBucket
                _count += .one
                return true
            }

            if storedHash == hash {
                let existingPosition = self[position: currentBucket]
                if equals(existingPosition) {
                    return false
                }
            }

            currentBucket = bucket.next(currentBucket)
            probes += .one
        }

        return false
    }

    @inlinable
    @discardableResult
    public mutating func insert<Context: ~Copyable>(
        position: Index<Element>,
        hashValue: Hash.Value,
        context: borrowing Context,
        equals: (Index<Element>, borrowing Context) -> Bool
    ) -> Bool {
        if shouldGrow {
            grow()
        }

        let hash = Self.normalize(hashValue)
        var currentBucket = bucket.for(hash: hash)
        var probes: Index<Bucket>.Count = .zero
        let cap = bucketCapacity

        while probes < cap {
            let storedHash = self[hash: currentBucket]

            if storedHash == Self.empty {
                self[hash: currentBucket] = hash
                self[position: currentBucket] = position
                self[bucketOfRank: position] = currentBucket
                _count += .one
                return true
            }

            if storedHash == hash {
                let existingPosition = self[position: currentBucket]
                if equals(existingPosition, context) {
                    return false
                }
            }

            currentBucket = bucket.next(currentBucket)
            probes += .one
        }

        return false
    }

    @inlinable
    public mutating func insert(
        _unchecked: Void,
        position: Index<Element>,
        hashValue: Hash.Value
    ) {
        if shouldGrow {
            grow()
        }

        let hash = Self.normalize(hashValue)
        var currentBucket = bucket.for(hash: hash)
        var probes: Index<Bucket>.Count = .zero
        let cap = bucketCapacity

        while probes < cap {
            let storedHash = self[hash: currentBucket]

            if storedHash == Self.empty {
                self[hash: currentBucket] = hash
                self[position: currentBucket] = position
                self[bucketOfRank: position] = currentBucket
                _count += .one
                return
            }

            currentBucket = bucket.next(currentBucket)
            probes += .one
        }
    }

    @inlinable
    package mutating func grow() {
        let oldCapacity = bucketCapacity
        let newSeed = Self.makeSeed()
        let newCapacity = Index<Bucket>.Count.max(
            Index<Bucket>.Count(Cardinal(8 as UInt)),
            oldCapacity * 2
        )
        var newBuffer = Buffer<
            Store.Split<
                Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>,
                Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>
            >
        >.Slots(
            capacity: newCapacity.retag(Int.self),
            metadataInitial: Self.empty
        )
        newBuffer.fill(payload: 0)
        var newPlane = Self.makeRankPlane(bucketCapacity: newCapacity)

        var bucket: Bucket.Index = .zero
        var remaining = _count
        while bucket < oldCapacity, remaining != .zero {
            let hash = self[hash: bucket]
            if hash != Self.empty {
                let position = self[position: bucket]
                var targetBucket = Self.bucket(for: hash, seed: newSeed, capacity: newCapacity)

                var probes: Index<Bucket>.Count = .zero
                while newBuffer[metadata: targetBucket.retag(Int.self)] != Self.empty
                    && probes < newCapacity
                {
                    targetBucket = Bucket.Index.Modular.successor(
                        of: targetBucket,
                        capacity: newCapacity
                    )
                    probes += .one
                }

                newBuffer[metadata: targetBucket.retag(Int.self)] = hash
                let rankRaw = Int(bitPattern: position)
                newBuffer[payload: targetBucket.retag(Int.self)] = rankRaw

                if rankRaw < Int(bitPattern: newPlane.count) {
                    newPlane[Index<Int>(_unchecked: Ordinal(UInt(bitPattern: rankRaw)))] = Int(
                        bitPattern: targetBucket
                    )
                }
                remaining = remaining.subtract.saturating(.one)
            }
            bucket += .one
        }

        _seed = newSeed
        _buffer = newBuffer
        _rankToBucket = newPlane
    }
}
