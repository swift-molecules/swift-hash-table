public import Hash
public import Store
public import Tagged
public import Ordinal
public import Cardinal
public import Ownership
public import Index

extension Hash.Table: __HashTableProtocol where Element: ~Copyable {

    public typealias Position = Index<Element>
}
