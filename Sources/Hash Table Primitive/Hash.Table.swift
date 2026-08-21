public import Affine_Primitives_Standard_Library_Integration
public import Buffer_Linear_Primitive
public import Buffer_Primitive
public import Buffer_Slots_Primitive
import Cardinal_Primitives
internal import Cyclic_Index_Primitives
internal import Finite_Primitives
import Hash_Primitives
public import Index_Primitives
public import Memory_Allocator_Primitive
public import Memory_Heap_Primitives
internal import Ordinal_Primitives
public import Storage_Contiguous_Primitives
public import Storage_Primitive
public import Store_Primitive
public import Store_Split_Primitives

extension Hash {

    @safe
    @frozen
    public struct Table<Element: ~Copyable>: ~Copyable {

        @usableFromInline
        package var _count: Index<Element>.Count

        @usableFromInline
        package var _seed: Int

        @usableFromInline
        package var _buffer:
            Buffer<
                Store.Split<
                    Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>,
                    Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>
                >
            >.Slots

        @usableFromInline
        package var _rankToBucket:
            Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear

        @inlinable
        package static var empty: Int { 0 }

        @inlinable
        public init(minimumCapacity: Index<Element>.Count = .zero) {
            let hashCapacity = Self.bucketCapacity(for: minimumCapacity)
            _count = .zero
            _seed = Self.makeSeed()
            var buffer = Buffer<
                Store.Split<
                    Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>,
                    Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>
                >
            >.Slots(
                capacity: hashCapacity.retag(Int.self),
                metadataInitial: Self.empty
            )
            buffer.fill(payload: 0)
            _buffer = buffer
            _rankToBucket = Self.makeRankPlane(bucketCapacity: hashCapacity)
        }

        @inlinable
        package static func makeRankPlane(
            bucketCapacity: Index<Bucket>.Count
        ) -> Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear {
            var plane = Buffer<Storage<Memory.Allocator<Memory.Heap>>.Contiguous<Int>>.Linear(
                minimumCapacity: bucketCapacity.retag(Int.self)
            )

            plane.append(addingCapacity: bucketCapacity.retag(Int.self)) {
                (span: inout Swift.OutputSpan<Int>) in
                while !span.isFull {
                    span.append(0)
                }
            }
            return plane
        }

        @inlinable
        package static func bucketCapacity(
            for minimumCapacity: Index<Element>.Count
        ) -> Index<Bucket>.Count {
            let minCap = Int(bitPattern: minimumCapacity)
            guard minCap > 0 else {
                return Index<Bucket>.Count(Cardinal(8))
            }

            let needed = max(8, (minCap * 10) / 7)

            let powerOfTwo = 1 << (Int.bitWidth - (needed - 1).leadingZeroBitCount)
            return Index<Bucket>.Count(Cardinal(UInt(powerOfTwo)))
        }

        @inlinable
        package static func normalize(_ hashValue: Hash.Value) -> Int {
            let raw = hashValue.underlying
            return raw == 0 ? 1 : raw
        }

        @inlinable
        package static func makeSeed() -> Int {
            var generator = SystemRandomNumberGenerator()
            return Int(bitPattern: UInt(truncatingIfNeeded: generator.next() as UInt64))
        }

    }
}

extension Hash.Table: @unsafe @unchecked Sendable where Element: Sendable {}
