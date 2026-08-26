public import Buffer_Linear_Primitive
import Buffer_Primitive
public import Buffer_Slots_Primitive
import Buffer_Slots
import Hash
public import Index
public import Memory_Allocator_Primitive
public import Memory_Heap
public import Storage_Contiguous
public import Storage_Primitive
public import Store_Primitive
public import Store_Split

extension Hash.Table where Element: ~Copyable {

    @inlinable
    package var bucketCapacity: Index<Bucket>.Count {
        _buffer.capacity.retag(Bucket.self)
    }

    @inlinable
    package subscript(hash bucket: Bucket.Index) -> Int {
        get { _buffer[metadata: bucket.retag(Int.self)] }
        set { _buffer[metadata: bucket.retag(Int.self)] = newValue }
    }

    @inlinable
    package subscript(position bucket: Bucket.Index) -> Index<Element> {
        get {
            let raw = _buffer[payload: bucket.retag(Int.self)]
            return Index<Element>(_unchecked: Ordinal(UInt(bitPattern: raw)))
        }
        set {
            _buffer[payload: bucket.retag(Int.self)] = Int(bitPattern: newValue)
        }
    }

    @inlinable
    package subscript(bucketOfRank rank: Index<Element>) -> Bucket.Index {
        get {
            let raw = _rankToBucket[
                Index<Int>(_unchecked: Ordinal(UInt(bitPattern: Int(bitPattern: rank))))
            ]
            return Bucket.Index(_unchecked: Ordinal(UInt(bitPattern: raw)))
        }
        set {
            let raw = Int(bitPattern: rank)
            guard raw < Int(bitPattern: _rankToBucket.count) else { return }
            _rankToBucket[Index<Int>(_unchecked: Ordinal(UInt(bitPattern: raw)))] = Int(
                bitPattern: newValue
            )
        }
    }
}
