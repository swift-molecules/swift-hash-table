public import Buffer_Linear_Primitive
public import Buffer_Slots
public import Cardinal
public import Hash
public import Index
public import Memory
public import Memory_Allocator_Primitive
public import Memory_Small
public import Ordinal
public import Storage
public import Storage_Memory
public import Store_Split
public import Tagged

extension Hash.Table where Element: ~Copyable {

    @inlinable
    package var bucketCapacity: Tagged<Bucket, Cardinal> {
        _buffer.capacity.retag(Bucket.self)
    }

    @inlinable
    package subscript(hash bucket: Bucket.Position) -> Int {
        get { _buffer[metadata: bucket.retag(Int.self)] }
        set { _buffer[metadata: bucket.retag(Int.self)] = newValue }
    }

    @inlinable
    package subscript(position bucket: Bucket.Position) -> Index<Element> {
        get {
            let raw = _buffer[payload: bucket.retag(Int.self)]
            return Index<Element>(_unchecked: Ordinal(UInt(bitPattern: raw)))
        }
        set {
            _buffer[payload: bucket.retag(Int.self)] = Int(
                bitPattern: newValue.underlying.rawValue
            )
        }
    }

    @inlinable
    package subscript(bucketOfRank rank: Index<Element>) -> Bucket.Position {
        get {
            let raw = _rankToBucket[
                Index<Int>(_unchecked: Ordinal(rank.underlying.rawValue))
            ]
            return Bucket.Position(_unchecked: Ordinal(UInt(bitPattern: raw)))
        }
        set {
            let raw = Int(bitPattern: rank.underlying.rawValue)
            guard raw < Int(bitPattern: _rankToBucket.count.underlying.rawValue) else { return }
            _rankToBucket[Index<Int>(_unchecked: Ordinal(UInt(bitPattern: raw)))] = Int(
                bitPattern: newValue.underlying.rawValue
            )
        }
    }
}
