public import Buffer_Linear_Primitive
public import Buffer_Primitive
public import Hash_Indexed_Primitive
import Hash
import Hash_Table_Primitive
import Index
public import Memory_Allocator_Primitive
public import Memory_Heap
import Ordinal_Standard_Library_Integration
public import Storage_Contiguous
public import Storage_Primitive

extension Hash {

    public enum Coherence {}
}

extension Hash.Coherence {

    public static func violations<E: Hash.Key & Copyable>(
        _ column: borrowing Hash.Indexed<Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<E>>.Linear>
    ) -> [String] {
        var found: [String] = []
        let end = column.count.map(Ordinal.init)

        var slot: Index<E> = .zero
        while slot < end {
            let foundPosition = column.position(of: column[slot])
            if foundPosition != slot {
                found.append("law 1: the member at dense slot \(slot) resolves to \(String(describing: foundPosition))")
            }
            slot = slot.successor.saturating()
        }

        var bucket: Hash.Table<E>.Bucket.Index = .zero
        let bucketEnd = column.indices.bucketCapacity.map(Ordinal.init)
        var liveEntries: Index<E>.Count = .zero
        while bucket < bucketEnd {
            let storedHash = column.indices[hash: bucket]
            if storedHash != Hash.Table<E>.empty {
                liveEntries += .one
                let position = column.indices[position: bucket]
                if position < end {
                    let memberHash = Hash.Table<E>.normalize(column[position].hashValue)
                    if memberHash != storedHash {
                        found.append("law 2: bucket \(bucket) stores hash \(storedHash) but the member at dense slot \(position) hashes to \(memberHash)")
                    }
                } else {
                    found.append("law 2: bucket \(bucket) holds position \(position) beyond the dense count \(column.count)")
                }
            }
            bucket = bucket.successor.saturating()
        }

        if column.indices._count != column.count {
            found.append("law 3: the engine counts \(column.indices._count) but the dense plane holds \(column.count)")
        }
        if liveEntries != column.count {
            found.append("law 3: \(liveEntries) live bucket entries but the dense plane holds \(column.count)")
        }

        bucket = .zero
        while bucket < bucketEnd {
            if column.indices[hash: bucket] != Hash.Table<E>.empty {
                let position = column.indices[position: bucket]
                let back = column.indices[bucketOfRank: position]
                if back != bucket {
                    found.append("law 4: bucket \(bucket) holds rank \(position) but the back-pointer names bucket \(back)")
                }
            }
            bucket = bucket.successor.saturating()
        }
        return found
    }
}
