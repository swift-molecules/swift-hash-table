public import Buffer_Slots
public import Cardinal
public import Hash
public import Index
public import Ordinal
public import Tagged

extension Hash.Table where Element: ~Copyable {

    @inlinable
    public borrowing func position(
        forHash hashValue: Hash.Value,
        equals: (Index<Element>) -> Bool
    ) -> Index<Element>? {
        let hash = Self.normalize(hashValue)
        let capacityCount = bucketCapacity

        let capacity = Int(bitPattern: capacityCount.underlying.rawValue)
        let mask = capacity &- 1
        var bucket = Int(
            bitPattern: Self.bucket(for: hash, seed: _seed, capacity: capacityCount).underlying
                .rawValue
        )
        var probes = 0

        return unsafe _buffer.withMetadataPointer {
            (hashes: UnsafePointer<Int>) -> Index<Element>? in
            while probes < capacity {

                let storedHash = unsafe hashes[bucket]

                if storedHash == Self.empty {
                    return nil
                }

                if storedHash == hash {
                    let position = self[
                        position: Bucket.Position(_unchecked: Ordinal(UInt(bitPattern: bucket)))
                    ]
                    if equals(position) {
                        return position
                    }
                }

                bucket = (bucket &+ 1) & mask
                probes &+= 1
            }

            return nil
        }
    }

    @inlinable
    public borrowing func position<Context: ~Copyable>(
        forHash hashValue: Hash.Value,
        context: borrowing Context,
        equals: (Index<Element>, borrowing Context) -> Bool
    ) -> Index<Element>? {
        let hash = Self.normalize(hashValue)
        let capacityCount = bucketCapacity

        let capacity = Int(bitPattern: capacityCount.underlying.rawValue)
        let mask = capacity &- 1
        var bucket = Int(
            bitPattern: Self.bucket(for: hash, seed: _seed, capacity: capacityCount).underlying
                .rawValue
        )
        var probes = 0
        return unsafe _buffer.withMetadataPointer {
            (hashes: UnsafePointer<Int>) -> Index<Element>? in
            while probes < capacity {

                let storedHash = unsafe hashes[bucket]

                if storedHash == Self.empty {
                    return nil
                }

                if storedHash == hash {
                    let position = self[
                        position: Bucket.Position(_unchecked: Ordinal(UInt(bitPattern: bucket)))
                    ]
                    if equals(position, context) {
                        return position
                    }
                }

                bucket = (bucket &+ 1) & mask
                probes &+= 1
            }

            return nil
        }
    }

    @inlinable
    public borrowing func index(
        forHash hashValue: Hash.Value,
        equals: (Index<Element>) -> Bool
    ) -> Bucket.Position? {
        let hash = Self.normalize(hashValue)
        let capacityCount = bucketCapacity

        let capacity = Int(bitPattern: capacityCount.underlying.rawValue)
        let mask = capacity &- 1
        var bucket = Int(
            bitPattern: Self.bucket(for: hash, seed: _seed, capacity: capacityCount).underlying
                .rawValue
        )
        var probes = 0
        return unsafe _buffer.withMetadataPointer { (hashes: UnsafePointer<Int>) -> Bucket.Position? in
            while probes < capacity {

                let storedHash = unsafe hashes[bucket]

                if storedHash == Self.empty {
                    return nil
                }

                if storedHash == hash {
                    let found = Bucket.Position(_unchecked: Ordinal(UInt(bitPattern: bucket)))
                    let position = self[position: found]
                    if equals(position) {
                        return found
                    }
                }

                bucket = (bucket &+ 1) & mask
                probes &+= 1
            }

            return nil
        }
    }

    @inlinable
    public borrowing func index<Context: ~Copyable>(
        forHash hashValue: Hash.Value,
        context: borrowing Context,
        equals: (Index<Element>, borrowing Context) -> Bool
    ) -> Bucket.Position? {
        let hash = Self.normalize(hashValue)
        let capacityCount = bucketCapacity

        let capacity = Int(bitPattern: capacityCount.underlying.rawValue)
        let mask = capacity &- 1
        var bucket = Int(
            bitPattern: Self.bucket(for: hash, seed: _seed, capacity: capacityCount).underlying
                .rawValue
        )
        var probes = 0
        return unsafe _buffer.withMetadataPointer { (hashes: UnsafePointer<Int>) -> Bucket.Position? in
            while probes < capacity {

                let storedHash = unsafe hashes[bucket]

                if storedHash == Self.empty {
                    return nil
                }

                if storedHash == hash {
                    let found = Bucket.Position(_unchecked: Ordinal(UInt(bitPattern: bucket)))
                    let position = self[position: found]
                    if equals(position, context) {
                        return found
                    }
                }

                bucket = (bucket &+ 1) & mask
                probes &+= 1
            }

            return nil
        }
    }

    @inlinable
    public borrowing func contains(
        hashValue: Hash.Value,
        equals: (Index<Element>) -> Bool
    ) -> Bool {
        if case .some = position(forHash: hashValue, equals: equals) {
            return true
        }
        return false
    }

    @inlinable
    public borrowing func contains<Context: ~Copyable>(
        forHash hashValue: Hash.Value,
        context: borrowing Context,
        equals: (Index<Element>, borrowing Context) -> Bool
    ) -> Bool {
        if case .some = position(forHash: hashValue, context: context, equals: equals) {
            return true
        }
        return false
    }
}
