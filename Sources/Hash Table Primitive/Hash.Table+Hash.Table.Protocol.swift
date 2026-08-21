public import Hash_Primitives
public import Index_Primitives

extension Hash.Table: __HashTableProtocol where Element: ~Copyable {

    public typealias Position = Index<Element>
}
