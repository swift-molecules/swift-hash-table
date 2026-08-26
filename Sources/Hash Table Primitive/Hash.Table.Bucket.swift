public import Hash
public import Index

extension Hash.Table where Element: ~Copyable {

    public struct Bucket: ~Copyable {}
}

extension Hash.Table.Bucket where Element: ~Copyable {

    public typealias Index = Index.Index<Self>

    public enum Ops {}
}
