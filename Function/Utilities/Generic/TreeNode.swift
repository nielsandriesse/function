import Foundation

protocol TreeNode {
    associatedtype Node
    var children: [Node] { get }
}

protocol BidirectionalTreeNode : TreeNode {
    var parent: Node? { get }
}

extension TreeNode where Node == Self {

    /// Returns the descendant at `indexPath` with respect to `self`.
    func descendant(at indexPath: IndexPath) -> Node {
        return indexPath.reduce(self) { $0.children[$1] }
    }

    /// Returns the descendant at `indexPath` with respect to `self` if present, or `nil` otherwise.
    func descendantIfPresent(at indexPath: IndexPath) -> Node? {
        return indexPath.failableReduce(self) { $0.children[ifValid: $1] }
    }
}

extension BidirectionalTreeNode where Node == Self, Node : Equatable {

    /// The index of `self` in its parent's children.
    var index: Int? {
        guard let parent = parent else { return nil }
        return parent.children.index(of: self) ?? preconditionFailure("Node is not a child of its parent.")
    }

    /// The index path of `self` with respect to its root ancestor.
    var indexPath: IndexPath {
        guard let parent = parent, let index = index else { return [] }
        return parent.indexPath.appending(index)
    }
}
