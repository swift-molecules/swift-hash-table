import Cardinal
public import Index
import Ordinal
import Ownership
import Store
public import Tagged

extension Hash.Table: __HashTableProtocol where Element: ~Copyable {

    public typealias Position = Index<Element>
}
