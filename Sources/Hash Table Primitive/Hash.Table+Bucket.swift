public import Hash_Value
public import Hash_Protocol
public import Store_Initialization
public import Store_Operations
public import Store_Protocol
public import Store
public import Index
public import Ordinal_Tagged
public import Ordinal_Protocol
public import Ordinal_Cardinal
public import Cardinal_Tagged
public import Cardinal_Carrier
public import Ownership_Inout
public import Ownership_Borrow
public import Cyclic_Index
public import Cardinal
public import Hash
public import Ordinal
public import Ownership
public import Property
public import Property_Ownership
public import Tagged

extension Hash.Table.Bucket.Ops where Element: ~Copyable {

    public typealias View = Property<Hash.Table<Element>.Bucket.Ops, Hash.Table<Element>>.Inout
        .Typed<Element>
}

extension Hash.Table where Element: ~Copyable {

    @inlinable
    package static func bucket(
        for hash: Int,
        seed: Int,
        capacity: Tagged<Bucket, Cardinal>
    ) -> Bucket.Position {
        Bucket.Position(
            _unchecked: Ordinal(
                UInt(bitPattern: hash ^ seed) % capacity.underlying.rawValue
            )
        )
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
    public func `for`(hash: Int) -> Hash.Table<Element>.Bucket.Position {
        let capacity = base.value.bucketCapacity
        return Hash.Table<Element>.bucket(for: hash, seed: base.value._seed, capacity: capacity)
    }

    @inlinable
    public func next(_ bucket: Hash.Table<Element>.Bucket.Position) -> Hash.Table<Element>.Bucket.Position
    {
        let capacity = base.value.bucketCapacity
        return Hash.Table<Element>.Bucket.Position.Modular.successor(of: bucket, capacity: capacity)
    }
}
