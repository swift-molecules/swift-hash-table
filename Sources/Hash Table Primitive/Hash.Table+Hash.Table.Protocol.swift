public import Hash
public import Index

extension Hash.Table: __HashTableProtocol where Element: ~Copyable {

    public typealias Position = Index<Element>
}
