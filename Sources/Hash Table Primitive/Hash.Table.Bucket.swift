public import Hash_Value
public import Hash_Protocol
public import Store_Initialization
public import Store_Operations
public import Store_Protocol
public import Store
public import Index
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
public import struct Index.Index

extension Hash.Table where Element: ~Copyable {

    public struct Bucket: ~Copyable {}
}

extension Hash.Table.Bucket where Element: ~Copyable {

    public typealias Position = Index<Self>

    public enum Ops {}
}
