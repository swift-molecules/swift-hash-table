public import Hash_Primitives
public import Index_Primitives

extension Hash.Table where Element: ~Copyable {

    public struct Bucket: ~Copyable {}
}

extension Hash.Table.Bucket where Element: ~Copyable {

    public typealias Index = Index_Primitives.Index<Self>

    public enum Ops {}
}
