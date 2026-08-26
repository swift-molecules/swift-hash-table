public import Hash
public import Index
import Ordinal
internal import Property

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
        let removedRaw = Int(bitPattern: removedPosition)
        var rank = Index<Element>(_unchecked: Ordinal(UInt(bitPattern: removedRaw + 1)))
        let end = base.value._count.map(Ordinal.init)
        while rank <= end {
            let bucket = base.value[bucketOfRank: rank]
            let rankRaw = Int(bitPattern: rank)
            let lowered = Index<Element>(_unchecked: Ordinal(UInt(bitPattern: rankRaw - 1)))
            base.value[position: bucket] = lowered
            base.value[bucketOfRank: lowered] = bucket
            rank = Index<Element>(_unchecked: Ordinal(UInt(bitPattern: rankRaw + 1)))
        }
    }
}
