import Cardinal
public import Index
import Ordinal
import Ownership
import Store
public import Tagged

extension Hash.Table where Element: ~Copyable {

    public struct Bucket: ~Copyable {}
}

extension Hash.Table.Bucket where Element: ~Copyable {

    public typealias Position = Index<Self>

    public enum Ops {}
}
