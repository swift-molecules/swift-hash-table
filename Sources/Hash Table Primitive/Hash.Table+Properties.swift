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
public import Ordinal
public import Cardinal_Tagged
public import Cardinal_Carrier
public import Ownership_Inout
public import Ownership_Borrow
public import Cardinal
public import Hash
public import Tagged

extension Hash.Table where Element: ~Copyable {

    @inlinable
    public var count: Tagged<Element, Cardinal> {
        _count
    }

    @inlinable
    public var isEmpty: Bool {
        _count.underlying.rawValue == 0
    }

    @inlinable
    public var capacity: Tagged<Bucket, Cardinal> {
        bucketCapacity
    }

    @inlinable
    package var shouldGrow: Bool {
        _count.underlying.rawValue &* 10 >= bucketCapacity.underlying.rawValue &* 7
    }
}
