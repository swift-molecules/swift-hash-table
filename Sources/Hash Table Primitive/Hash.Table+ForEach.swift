public import Hash_Value
public import Hash_Protocol
public import Store_Initialization
public import Store_Operations
public import Store_Protocol
public import Store
public import Ordinal_Tagged
public import Ordinal_Protocol
public import Ordinal_Cardinal
public import Cardinal_Tagged
public import Cardinal_Carrier
public import Ownership_Inout
public import Ownership_Borrow
public import Cardinal
public import Hash
public import Index
public import Ordinal
public import Ownership
public import Property
public import Property_Ownership
public import Tagged

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
    public func occupied(_ body: (Hash.Table<Element>.Bucket.Position, Index<Element>) -> Void) {
        let cap = base.value.bucketCapacity
        var raw: UInt = 0
        while raw < cap.underlying.rawValue {
            let bucket = Hash.Table<Element>.Bucket.Position(_unchecked: Ordinal(raw))
            let hash = base.value[hash: bucket]
            if hash != Hash.Table<Element>.empty {
                let position = base.value[position: bucket]
                body(bucket, position)
            }
            raw &+= 1
        }
    }
}
