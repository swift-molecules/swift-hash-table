public import Hash_Protocol
public import Store_Initialization
public import Store_Operations
public import Store_Protocol
public import Store
public import Ordinal_Tagged
public import Ordinal_Protocol
public import Ordinal_Cardinal
public import Cardinal_Tagged
public import Cardinal_Carrier
public import Ownership_Inout
public import Ownership_Borrow
import Affine_Standard_Library_Integration
public import Buffer_Linear_Primitive
public import Buffer
public import Buffer_Slots
public import Cardinal
public import Cyclic_Index
public import Hash
public import Hash_Value
public import Index
public import Memory
public import Memory_Allocator
public import Memory_Small
public import Ordinal
public import Storage
public import Storage_Memory
public import Store_Split
public import Tagged

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
        var probes: UInt = 0
        let cap = bucketCapacity

        while probes < cap.underlying.rawValue {
            let storedHash = self[hash: currentBucket]

            if storedHash == Self.empty {
                self[hash: currentBucket] = hash
                self[position: currentBucket] = position
                self[bucketOfRank: position] = currentBucket
                _count = Tagged(_unchecked: Cardinal(_count.underlying.rawValue &+ 1))
                return true
            }

            if storedHash == hash {
                let existingPosition = self[position: currentBucket]
                if equals(existingPosition) {
                    return false
                }
            }

            currentBucket = bucket.next(currentBucket)
            probes &+= 1
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
        var probes: UInt = 0
        let cap = bucketCapacity

        while probes < cap.underlying.rawValue {
            let storedHash = self[hash: currentBucket]

            if storedHash == Self.empty {
                self[hash: currentBucket] = hash
                self[position: currentBucket] = position
                self[bucketOfRank: position] = currentBucket
                _count = Tagged(_unchecked: Cardinal(_count.underlying.rawValue &+ 1))
                return true
            }

            if storedHash == hash {
                let existingPosition = self[position: currentBucket]
                if equals(existingPosition, context) {
                    return false
                }
            }

            currentBucket = bucket.next(currentBucket)
            probes &+= 1
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
        var probes: UInt = 0
        let cap = bucketCapacity

        while probes < cap.underlying.rawValue {
            let storedHash = self[hash: currentBucket]

            if storedHash == Self.empty {
                self[hash: currentBucket] = hash
                self[position: currentBucket] = position
                self[bucketOfRank: position] = currentBucket
                _count = Tagged(_unchecked: Cardinal(_count.underlying.rawValue &+ 1))
                return
            }

            currentBucket = bucket.next(currentBucket)
            probes &+= 1
        }
    }

    @inlinable
    package mutating func grow() {
        let oldCapacity = bucketCapacity
        let newSeed = Self.makeSeed()
        let newCapacity = Tagged<Bucket, Cardinal>(
            Swift.max(8, oldCapacity.underlying.rawValue &* 2)
        )
        var newBuffer = Buffer<
            Store.Split<
                Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<Int>,
                Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<Int>
            >
        >.Slots(
            capacity: newCapacity.retag(Int.self),
            metadataInitial: Self.empty
        )
        newBuffer.fill(payload: 0)
        var newPlane = Self.makeRankPlane(bucketCapacity: newCapacity)

        var bucketRaw: UInt = 0
        var remaining = _count.underlying.rawValue
        while bucketRaw < oldCapacity.underlying.rawValue, remaining != 0 {
            let bucket = Bucket.Position(_unchecked: Ordinal(bucketRaw))
            let hash = self[hash: bucket]
            if hash != Self.empty {
                let position = self[position: bucket]
                var targetBucket = Self.bucket(for: hash, seed: newSeed, capacity: newCapacity)

                var probes: UInt = 0
                while newBuffer[metadata: targetBucket.retag(Int.self)] != Self.empty
                    && probes < newCapacity.underlying.rawValue
                {
                    targetBucket = Bucket.Position.Modular.successor(
                        of: targetBucket,
                        capacity: newCapacity
                    )
                    probes &+= 1
                }

                newBuffer[metadata: targetBucket.retag(Int.self)] = hash
                let rankRaw = Int(bitPattern: position.underlying.rawValue)
                newBuffer[payload: targetBucket.retag(Int.self)] = rankRaw

                if rankRaw < Int(bitPattern: newPlane.count.underlying.rawValue) {
                    newPlane[Index<Int>(_unchecked: Ordinal(UInt(bitPattern: rankRaw)))] = Int(
                        bitPattern: targetBucket.underlying.rawValue
                    )
                }
                remaining &-= 1
            }
            bucketRaw &+= 1
        }

        _seed = newSeed
        _buffer = newBuffer
        _rankToBucket = newPlane
    }
}
