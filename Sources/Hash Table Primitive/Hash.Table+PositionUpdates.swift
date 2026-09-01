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

extension Hash.Table.Positions where Element: ~Copyable {

    public typealias View = Property<Hash.Table<Element>.Positions, Hash.Table<Element>>.Inout
        .Typed<Element>
}

extension Hash.Table where Element: ~Copyable {

    @inlinable
    public var positions: Positions.View {
        mutating _read {
            yield.init(&self)
        }
        mutating _modify {
            var view: Positions.View = .init(&self)
            yield &view
        }
    }
}

extension Property.Inout.Typed
where Tag == Hash.Table<Element>.Positions, Base == Hash.Table<Element>, Element: ~Copyable {

    @inlinable
    public mutating func decrement(after removedPosition: Index<Element>) {
        var rankRaw = removedPosition.underlying.rawValue &+ 1
        let endRaw = base.value._count.underlying.rawValue
        while rankRaw <= endRaw {
            let rank = Index<Element>(_unchecked: Ordinal(rankRaw))
            let bucket = base.value[bucketOfRank: rank]
            let lowered = Index<Element>(_unchecked: Ordinal(rankRaw &- 1))
            base.value[position: bucket] = lowered
            base.value[bucketOfRank: lowered] = bucket
            rankRaw &+= 1
        }
    }
}
