public import Hash
public import Index
internal import Property

extension Hash.Table.ForEach where Element: ~Copyable {

    public typealias View = Property<Hash.Table<Element>.ForEach, Hash.Table<Element>>.Inout.Typed<
        Element
    >
}

extension Hash.Table where Element: ~Copyable {

    @inlinable
    public var forEach: ForEach.View {
        mutating _read {
            yield.init(&self)
        }
    }
}

extension Property.Inout.Typed
where Tag == Hash.Table<Element>.ForEach, Base == Hash.Table<Element>, Element: ~Copyable {

    @inlinable
    public func occupied(_ body: (Hash.Table<Element>.Bucket.Index, Index<Element>) -> Void) {
        var bucket: Hash.Table<Element>.Bucket.Index = .zero
        let cap = base.value.bucketCapacity
        while bucket < cap {
            let hash = base.value[hash: bucket]
            if hash != Hash.Table<Element>.empty {
                let position = base.value[position: bucket]
                body(bucket, position)
            }
            bucket += .one
        }
    }
}
