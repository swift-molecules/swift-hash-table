public import Ordinal_Tagged
public import Cardinal_Tagged
public import Cardinal_Carrier
public import Ownership_Borrow
public import Ownership_Inout
public import Hash_Value
public import Hash_Protocol
public import Buffer_Linear_Primitive
public import Buffer
import Cardinal
public import Hash_Indexed_Primitive
public import Hash
import Hash_Table_Primitive
import Index
public import Memory
public import Memory_Allocator
public import Memory_Small
import Ordinal
public import Storage
public import Storage_Memory
import Tagged

extension Hash {

    public enum Coherence {}
}

extension Hash.Coherence {

    public static func violations<E: Hash.Key & Copyable>(
        _ column: borrowing Hash.Indexed<Buffer<Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<E>>.Linear>
    ) -> [String] {
        var found: [String] = []
        let end = column.count.underlying.rawValue

        var slotRaw: UInt = 0
        while slotRaw < end {
            let slot = Index<E>(_unchecked: Ordinal(slotRaw))
            let foundPosition = column.position(of: column[slot])
            if foundPosition?.underlying.rawValue != slotRaw {
                found.append("law 1: the member at dense slot \(slot) resolves to \(String(describing: foundPosition))")
            }
            slotRaw &+= 1
        }

        let bucketEnd = column.indices.bucketCapacity.underlying.rawValue
        var bucketRaw: UInt = 0
        var liveEntries: UInt = 0
        while bucketRaw < bucketEnd {
            let bucket = Hash.Table<E>.Bucket.Position(_unchecked: Ordinal(bucketRaw))
            let storedHash = column.indices[hash: bucket]
            if storedHash != Hash.Table<E>.empty {
                liveEntries &+= 1
                let position = column.indices[position: bucket]
                if position.underlying.rawValue < end {
                    let memberHash = Hash.Table<E>.normalize(column[position].hashValue)
                    if memberHash != storedHash {
                        found.append("law 2: bucket \(bucket) stores hash \(storedHash) but the member at dense slot \(position) hashes to \(memberHash)")
                    }
                } else {
                    found.append("law 2: bucket \(bucket) holds position \(position) beyond the dense count \(column.count)")
                }
            }
            bucketRaw &+= 1
        }

        if column.indices._count.underlying.rawValue != column.count.underlying.rawValue {
            found.append("law 3: the engine counts \(column.indices._count) but the dense plane holds \(column.count)")
        }
        if liveEntries != column.count.underlying.rawValue {
            found.append("law 3: \(liveEntries) live bucket entries but the dense plane holds \(column.count)")
        }

        bucketRaw = 0
        while bucketRaw < bucketEnd {
            let bucket = Hash.Table<E>.Bucket.Position(_unchecked: Ordinal(bucketRaw))
            if column.indices[hash: bucket] != Hash.Table<E>.empty {
                let position = column.indices[position: bucket]
                let back = column.indices[bucketOfRank: position]
                if back.underlying.rawValue != bucketRaw {
                    found.append("law 4: bucket \(bucket) holds rank \(position) but the back-pointer names bucket \(back)")
                }
            }
            bucketRaw &+= 1
        }
        return found
    }
}
