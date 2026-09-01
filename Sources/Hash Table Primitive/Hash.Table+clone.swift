import Affine_Standard_Library_Integration
public import Buffer_Linear_Primitive
public import Buffer
public import Buffer_Slots
public import Cardinal
public import Hash
public import Index
public import Memory
public import Memory_Allocator
public import Memory_Small
public import Ordinal
import Ordinal_Standard_Library_Integration
public import Storage
public import Storage_Memory
public import Store_Split
public import Tagged

extension Hash.Table where Element: ~Copyable {

    @inlinable
    public borrowing func clone() -> Self {
        var copy = Self(minimumCapacity: .zero)
        var fresh = Buffer<
            Store.Split<
                Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<Int>,
                Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<Int>
            >
        >.Slots(
            capacity: self.bucketCapacity.retag(Int.self),
            metadataInitial: Self.empty
        )
        fresh.fill(payload: 0)
        var freshPlane = Self.makeRankPlane(bucketCapacity: self.bucketCapacity)
        var bucket: Index<Int> = .zero
        let end = self.bucketCapacity.retag(Int.self).map { Ordinal($0.rawValue) }
        while bucket < end {
            fresh[metadata: bucket] = _buffer[metadata: bucket]
            fresh[payload: bucket] = _buffer[payload: bucket]
            freshPlane[bucket] = _rankToBucket[bucket]
            bucket += .one
        }
        copy._buffer = fresh
        copy._rankToBucket = freshPlane
        copy._count = _count
        copy._seed = _seed
        return copy
    }
}
