public import Hash_Primitives
import Index_Primitives

public protocol __HashTableProtocol: ~Copyable {

    associatedtype Position

    borrowing func position(
        forHash hashValue: Hash.Value,
        equals: (Position) -> Bool
    ) -> Position?

    borrowing func position<Context: ~Copyable>(
        forHash hashValue: Hash.Value,
        context: borrowing Context,
        equals: (Position, borrowing Context) -> Bool
    ) -> Position?
}

extension __HashTableProtocol where Self: ~Copyable {

    @inlinable
    public borrowing func contains<Context: ~Copyable>(
        forHash hashValue: Hash.Value,
        context: borrowing Context,
        equals: (Position, borrowing Context) -> Bool
    ) -> Bool {
        position(forHash: hashValue, context: context, equals: equals) != nil
    }
}

extension Hash.Table where Element: ~Copyable {

    public typealias `Protocol` = __HashTableProtocol
}
