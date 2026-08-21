import Affine_Primitives_Standard_Library_Integration
public import Hash_Primitives
public import Index_Primitives

extension Hash.Table where Element: ~Copyable {

    @inlinable
    public var count: Index<Element>.Count {
        _count
    }

    @inlinable
    public var isEmpty: Bool {
        _count == .zero
    }

    @inlinable
    public var capacity: Index<Bucket>.Count {
        bucketCapacity
    }

    @inlinable
    package var shouldGrow: Bool {
        typealias Scale = Affine.Discrete.Ratio<Bucket, Bucket>
        return _count.retag(Bucket.self) * Scale(10) >= bucketCapacity * Scale(7)
    }
}
