public import Hash_Protocol
public import Store_Initialization
public import Store_Operations
public import Store_Protocol
public import Store
public import Tagged
public import Ordinal_Tagged
public import Ordinal_Protocol
public import Ordinal_Cardinal
public import Ordinal
public import Cardinal_Tagged
public import Cardinal_Carrier
public import Ownership_Inout
public import Ownership_Borrow
public import Hash
public import Hash_Value
import Index

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
