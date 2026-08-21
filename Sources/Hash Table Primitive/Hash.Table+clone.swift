import Affine_Primitives_Standard_Library_Integration
public import Buffer_Linear_Primitive
public import Buffer_Primitive
public import Buffer_Slots_Primitive
import Buffer_Slots_Primitives
import Cardinal_Primitives
import Hash_Primitives
public import Index_Primitives
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
internal import Ordinal_Primitives
import Ordinal_Primitives_Standard_Library_Integration
public import Storage_Contiguous_Primitives
public import Storage_Primitive
public import Store_Primitive
public import Store_Split_Primitives

extension Hash.Table where Element: ~Copyable {

    @inlinable
    public borrowing func clone() -> Self {
        var copy = Self(minimumCapacity: .zero)
        var fresh = Buffer<
            Store.Split<
                Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>,
                Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>
            >
        >.Slots(
            capacity: self.bucketCapacity.retag(Int.self),
            metadataInitial: Self.empty
        )
        fresh.fill(payload: 0)
        var freshPlane = Self.makeRankPlane(bucketCapacity: self.bucketCapacity)
        var bucket: Index<Int> = .zero
        let end = self.bucketCapacity.retag(Int.self).map(Ordinal.init)
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
