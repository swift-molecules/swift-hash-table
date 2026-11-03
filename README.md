# swift-hash-table

Use this package when you are building a hashed collection and need the index underneath it. `Hash.Table<Element>` maps hash values to positions in storage the caller owns: it never holds elements, and the caller's `equals` closure, given a candidate position, decides identity. `Hash.Indexed<Dense>` puts a `Hash.Table<Element>` over a dense store and gives you an insertion-ordered set of `Swift.Hashable` members. Start from `Hash.Indexed<Dense>` for a ready-made unique column; start from `Hash.Table<Element>` when your collection owns its own storage. For a ready ordered set or ordered dictionary, use the swift-set-ordered or swift-dictionary-ordered packages, which build on this one.

## Laws

- `Hash.Table<Element>` probes linearly and removes by backward shift, leaving no tombstones: the number of occupied buckets always equals `count`, and every remaining entry stays findable after a removal, including in a cluster that wraps past the last bucket.
- A hash value of 0 is stored as 1, because 0 marks an empty bucket. Stored hashes are compared before `equals` is called, so `equals` only ever sees positions whose stored hash matches.
- The bucket count is a power of two, at least 8. Before each insert, when `count` reaches 7/10 of the bucket count, the bucket count doubles and every entry is rehashed under a newly drawn random seed. Bucket layout therefore differs between instances and runs, and a bucket's contents can change on any insert or removal. Positions, order, membership and counts never depend on the seed.
- An insert that does take `equals` returns `false` and changes nothing when an entry with the same hash satisfies `equals`. The `_unchecked:` insert skips that check.
- Positions are expected to be dense ranks `0..<count`. `positions.decrement(after:)` lowers every position above the removed one by one, and keeps each rank's link back to its bucket correct.
- `remove.all(keepingCapacity:)` keeps the bucket count only when asked to. By default it shrinks the table back to 8 buckets. Neither form draws a new seed.
- `clone()` returns an independent table with the same seed and bucket layout. Changes to either copy never reach the other.
- `Hash.Indexed<Dense>` keeps members in insertion order at dense slots `0..<count`, and `position(of:)` of a member is its slot. `forEach` visits members in that order.
- Inserting a member equal to one already present hands back the argument and leaves the stored member untouched. Otherwise the new member is appended at the back.
- Removing a member shifts every later member down one slot, which costs time linear in the members after it, so order is preserved. It returns the stored member.
- Writing through the subscript re-indexes the slot only if the member's hash value changed.
- `clone()` of a `Hash.Indexed<Dense>` detaches both the dense store and the index.
- Every move-only member is destroyed exactly once, whether it was removed, handed back as a duplicate, or still held when the column is destroyed.
