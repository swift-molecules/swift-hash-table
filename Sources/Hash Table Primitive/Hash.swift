public import Tagged

public enum Hash: Sendable {}

extension Hash {

    public typealias Value = Tagged<Hash, Int>
}
