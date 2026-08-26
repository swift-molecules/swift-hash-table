public import Cyclic_Index
import Hash
public import Index
import Ordinal
internal import Property

extension Hash.Table.Bucket.Ops where Element: ~Copyable {

    public typealias View = Property<Hash.Table<Element>.Bucket.Ops, Hash.Table<Element>>.Inout
        .Typed<Element>
}

extension Hash.Table where Element: ~Copyable {

    @inlinable
    package static func bucket(
        for hash: Int,
        seed: Int,
        capacity: Index<Bucket>.Count
    ) -> Bucket.Index {
        Bucket.Index(_unchecked: Ordinal(UInt(bitPattern: hash ^ seed)) % capacity.underlying)
    }

    @inlinable
    public var bucket: Bucket.Ops.View {
        mutating _read {
            yield.init(&self)
        }
    }
}

extension Property.Inout.Typed
where Tag == Hash.Table<Element>.Bucket.Ops, Base == Hash.Table<Element>, Element: ~Copyable {

    @inlinable
    public func `for`(hash: Int) -> Hash.Table<Element>.Bucket.Index {
        let capacity = base.value.bucketCapacity
        return Hash.Table<Element>.bucket(for: hash, seed: base.value._seed, capacity: capacity)
    }

    @inlinable
    public func next(_ bucket: Hash.Table<Element>.Bucket.Index) -> Hash.Table<Element>.Bucket.Index
    {
        let capacity = base.value.bucketCapacity
        return Hash.Table<Element>.Bucket.Index.Modular.successor(of: bucket, capacity: capacity)
    }
}
