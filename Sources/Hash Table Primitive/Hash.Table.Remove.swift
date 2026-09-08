public import Hash
public import Store
public import Tagged
public import Ordinal
public import Cardinal
public import Ownership
import Index

extension Hash.Table where Element: ~Copyable {

    public enum Remove {}
}
