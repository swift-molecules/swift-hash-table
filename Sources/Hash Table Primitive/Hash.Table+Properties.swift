public import Hash
public import Store
public import Index
public import Ordinal_Tagged
public import Ordinal_Protocol
public import Ordinal_Cardinal
public import Ordinal
public import Cardinal_Tagged
public import Cardinal_Carrier
public import Ownership
public import Cardinal
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
