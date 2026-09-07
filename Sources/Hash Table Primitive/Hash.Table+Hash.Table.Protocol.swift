public import Hash
public import Store
public import Tagged
public import Ordinal_Tagged
public import Ordinal_Protocol
public import Ordinal_Cardinal
public import Ordinal
public import Cardinal_Tagged
public import Cardinal_Carrier
public import Ownership
public import Index

extension Hash.Table: __HashTableProtocol where Element: ~Copyable {

    public typealias Position = Index<Element>
}
