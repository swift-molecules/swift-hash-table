import Store
public import Tagged
import Ordinal
import Cardinal
import Ownership
public import Index

extension Hash.Table: __HashTableProtocol where Element: ~Copyable {

    public typealias Position = Index<Element>
}
