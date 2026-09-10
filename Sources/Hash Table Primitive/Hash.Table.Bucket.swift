public import Hash
import Store
public import Index
public import Tagged
import Ordinal
import Cardinal
import Ownership
public import struct Index.Index

extension Hash.Table where Element: ~Copyable {

    public struct Bucket: ~Copyable {}
}

extension Hash.Table.Bucket where Element: ~Copyable {

    public typealias Position = Index<Self>

    public enum Ops {}
}
