public import Hash
public import Store
public import Index
public import Tagged
public import Ordinal
public import Cardinal
public import Ownership
public import struct Index.Index

extension Hash.Table where Element: ~Copyable {

    public struct Bucket: ~Copyable {}
}

extension Hash.Table.Bucket where Element: ~Copyable {

    public typealias Position = Index<Self>

    public enum Ops {}
}
