import Affine_Standard_Library_Integration
public import Buffer_Linear_Primitive
public import Buffer
public import Buffer_Slots
public import Cardinal
public import Hash
public import Memory
public import Memory_Allocator
public import Memory_Small
public import Storage
public import Storage_Memory
public import Store_Split
public import Tagged

extension Hash {

    @safe
    @frozen
    public struct Table<Element: ~Copyable>: ~Copyable {

        @usableFromInline
        package var _count: Tagged<Element, Cardinal>

        @usableFromInline
        package var _seed: Int

        @usableFromInline
        package var _buffer:
            Buffer<
                Store.Split<
                    Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<Int>,
                    Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<Int>
                >
            >.Slots

        @usableFromInline
        package var _rankToBucket:
            Buffer<Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<Int>>.Linear

        @inlinable
        package static var empty: Int { 0 }

        @inlinable
        public init(minimumCapacity: Tagged<Element, Cardinal> = .zero) {
            let hashCapacity = Self.bucketCapacity(for: minimumCapacity)
            _count = .zero
            _seed = Self.makeSeed()
            var buffer = Buffer<
                Store.Split<
                    Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<Int>,
                    Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<Int>
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
            bucketCapacity: Tagged<Bucket, Cardinal>
        ) -> Buffer<Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<Int>>.Linear {
            var plane = Buffer<Storage<Memory.Allocator<Memory.Small<0>>>.Contiguous<Int>>.Linear(
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
            for minimumCapacity: Tagged<Element, Cardinal>
        ) -> Tagged<Bucket, Cardinal> {
            let minCap = Int(bitPattern: minimumCapacity.underlying.rawValue)
            guard minCap > 0 else {
                return Tagged<Bucket, Cardinal>(8)
            }

            let needed = max(8, (minCap * 10) / 7)

            let powerOfTwo = 1 << (Int.bitWidth - (needed - 1).leadingZeroBitCount)
            return Tagged<Bucket, Cardinal>(UInt(powerOfTwo))
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
