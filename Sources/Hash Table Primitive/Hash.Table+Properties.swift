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
