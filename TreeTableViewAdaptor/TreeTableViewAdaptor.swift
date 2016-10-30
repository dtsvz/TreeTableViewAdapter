//
//  TreeTableViewAdaptor.swift
//  LETU
//
//  Created by Dmitrii Tsvetkov on 6/21/16.
//  Copyright © 2016. All rights reserved.
//

import UIKit

public protocol TreeNode {
    associatedtype T
    var opened: Bool { get set }
    var level: Int { get set }
    var hasChildren: Bool { get }
    func children <T where T: TreeNode> () -> [T]
}

public class TreeTableViewAdaptor <T where T: TreeNode> {
    private var openedNodes   = [TreeIndexPath]()
    private var flatTableData = [TreeIndexPath]()
    private var modelToIndexPathMap = [TreeIndexPath : T]()
    
    public var tableViewSection: Int = 0
    
    public var nodes = [T]() { didSet { prepareTableData() } }
    
    public func node(forIndexPath indexPath: NSIndexPath) -> T? {
        guard let treeIndexPath = indexPathToTreeIndexPath(indexPath) else { return nil }
        let model = node(forTreeIndexPath: treeIndexPath)
        return model
    }
    
    public func openNode(atIndexPath indexPath: NSIndexPath) {
        guard let treeIndexPath = indexPathToTreeIndexPath(indexPath) where !isNodeOpened(atTreeIndexPath: treeIndexPath) else { return }
        openedNodes.append(treeIndexPath)
        var item = node(forIndexPath: indexPath)
        item?.opened = true
        prepareTableData()
    }
    
    public func closeNode(atIndexPath indexPath: NSIndexPath) {
        guard let treeIndexPath = indexPathToTreeIndexPath(indexPath) where isNodeOpened(atTreeIndexPath: treeIndexPath) else { return }
        removeFromExpadedIndexPath(treeIndexPath)
        var item = node(forIndexPath: indexPath)
        item?.opened = false
        prepareTableData()
    }
    
    public func changeNodeState(atIndexPath indexPath: NSIndexPath) {
        let opened = isNodeOpened(atIndexPath: indexPath)
        
        guard opened else {
            openNode(atIndexPath: indexPath)
            return
        }
        closeNode(atIndexPath: indexPath)
    }
    
    public func isNodeOpened(atIndexPath indexPath: NSIndexPath) -> Bool {
        guard let treeIndexPath = indexPathToTreeIndexPath(indexPath) else { return false }
        return isNodeOpened(atTreeIndexPath: treeIndexPath)
    }
    
    public func hasChildren(indexPath: NSIndexPath) -> Bool {
        guard let treeIndexPath = indexPathToTreeIndexPath(indexPath) else { return false }
        let model = node(forTreeIndexPath: treeIndexPath)
        return model.hasChildren
    }
    
    public func childrenIndexPaths(forIndexPath indexPath: NSIndexPath) -> [NSIndexPath] {
        guard let treeIndexPath = indexPathToTreeIndexPath(indexPath) else { return [] }
        var result = [NSIndexPath]()
        guard hasChildren(indexPath) else { return result }
        guard let index = flatTableData.indexOf(treeIndexPath) else { return result }
        var curIndex = index + 1
        var curIndexPath: TreeIndexPath
        
        guard curIndex < flatTableData.count else { return result }
        curIndexPath = flatTableData[curIndex]
        
        var curRow = indexPath.row + 1
        while curIndexPath.length > treeIndexPath.length {
            result.append(NSIndexPath(forRow: curRow, inSection: tableViewSection))
            curIndex += 1
            curRow += 1
            guard curIndex < flatTableData.count else { return result }
            curIndexPath = flatTableData[curIndex]
        }
        
        return result
    }
    
    public func level(forIndexPath indexPath: NSIndexPath) -> Int {
        guard let treeIndexPath = indexPathToTreeIndexPath(indexPath) else { return 0 }
        return treeIndexPath.length
    }
    
    public func indexPath(forNodePredicate predicate: (T) -> Bool) -> NSIndexPath? {
        for (index, TreeIndexPath) in flatTableData.enumerate() {
            let item = node(forTreeIndexPath: TreeIndexPath)
            if predicate(item) {
                return NSIndexPath(forRow: index, inSection: tableViewSection)
            }
        }
        return nil
    }

    public func openToNode(nodeMatchingPredicate match: (T) -> Bool) {
        // TODO: Incorrect func behaviour - it collapses all nodes before opening to model
        closeAll()
        for (index, node) in nodes.enumerate() {
            let currentIndexPath = NSIndexPath(forRow: index, inSection: tableViewSection)
            guard !match(node) else {
                openNode(atIndexPath: currentIndexPath)
                break
            }
            guard node.hasChildren else { continue }
            let found = openToModel(modelMatchingPredicate: match, childNodes: node.children(), startIndex: index + 1, parentPaths: [currentIndexPath])
            guard !found else { break }
        }
    }
    
    public func openAll() {
        openedNodes = [TreeIndexPath]()
        flatTableData = buildFlatArray(nil, parentIndexPath: nil, openAll: true)
    }
    
    public func closeAll() {
        openedNodes = [TreeIndexPath]()
        prepareTableData()
    }
    
    /*
        MARK: - Private methods
    */
    
    private func prepareTableData() {
        flatTableData = [TreeIndexPath]()
        modelToIndexPathMap = [TreeIndexPath: T]()
        flatTableData = buildFlatArray()
    }
    
    private func buildFlatArray(parent: T? = nil, parentIndexPath: TreeIndexPath? = nil, openAll: Bool = false) -> [TreeIndexPath] {
        var flatArray = [TreeIndexPath]()
        guard let items = (parent != nil) ? parent?.children() : nodes else { return flatArray }
        
        for (index, item) in items.enumerate() {
            guard let indexPath = parentIndexPath != nil ? parentIndexPath?.indexPathByAddingIndex(index) : TreeIndexPath(indexPath: NSIndexPath(index: index)) else { continue }
            flatArray += [indexPath]
            modelToIndexPathMap[indexPath] = item
            
            var mutableItem = item
            mutableItem.level = indexPath.length
            mutableItem.opened = false
            
            guard (isNodeOpened(atTreeIndexPath: indexPath) || openAll) && item.hasChildren else { continue }
            mutableItem.opened = true
            flatArray += buildFlatArray(item, parentIndexPath: indexPath, openAll: openAll)
        }
        return flatArray
    }
    
    private func node(forTreeIndexPath treeIndexPath: TreeIndexPath) -> T {
        let model = modelToIndexPathMap[treeIndexPath]
        return model!
    }

    private func isNodeOpened(atTreeIndexPath treeIndexPath: TreeIndexPath) -> Bool {
        let index = openedNodes.indexOf(treeIndexPath)
        return index != nil
    }
    
    private func indexPathToTreeIndexPath(indexPath: NSIndexPath) -> TreeIndexPath? {
        guard isValidIndexPath(indexPath) else { return nil }
        let treeIndexPath = flatTableData[indexPath.row]
        return treeIndexPath
    }
    
    private func isValidIndexPath(indexPath: NSIndexPath) -> Bool {
        let row = indexPath.row
        guard row >= 0
              && row < flatTableData.count
              && tableViewSection == indexPath.section else { return false }
        return true
    }
    
    private func removeFromExpadedIndexPath(treeIndexPath: TreeIndexPath) {
        guard let index = openedNodes.indexOf(treeIndexPath) else { return }
        openedNodes.removeAtIndex(index)
    }
    
    private func openNodes(indexPaths: [NSIndexPath]) {
        indexPaths.forEach {
            openNode(atIndexPath: $0)
        }
    }
    
    private func openToModel(modelMatchingPredicate match: (T) -> Bool, childNodes: [T], startIndex: Int, parentPaths: [NSIndexPath]) -> Bool {
        for (index, node) in childNodes.enumerate() {
            let pathIndex = startIndex + index
            let currentIndexPath = NSIndexPath(forRow: pathIndex, inSection: tableViewSection)
            var newParentPaths = parentPaths
            newParentPaths.appendContentsOf(node.hasChildren ? [currentIndexPath] : [])
            guard !match(node) else {
                openNodes(newParentPaths)
                return true
            }
            guard node.hasChildren else { continue }
            let found = openToModel(modelMatchingPredicate: match, childNodes: node.children(), startIndex: pathIndex + 1, parentPaths: newParentPaths)
            if found { break }
        }
        return false
    }
}

extension TreeTableViewAdaptor {
    var numberOfRows: Int {
        return flatTableData.count
    }
    
    func changeNodeState(inTableView tableView: UITableView, atIndexPath indexPath: NSIndexPath) {
        guard hasChildren(indexPath) else { return }
        let childenIndexPaths = childrenIndexPaths(forIndexPath: indexPath)
        changeNodeState(atIndexPath: indexPath)
        
        if isNodeOpened(atIndexPath: indexPath) {
            let childenIndexPaths = childrenIndexPaths(forIndexPath: indexPath)
            tableView.insertRowsAtIndexPaths(childenIndexPaths, withRowAnimation: .Top)
        } else {
            tableView.deleteRowsAtIndexPaths(childenIndexPaths, withRowAnimation: .Fade)
        }
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
    }
}

private class TreeIndexPath : Hashable, Equatable {
    private var indexPath: NSIndexPath
    
    init(indexPath: NSIndexPath) {
        self.indexPath = indexPath
    }
    
    var length: Int {
        return indexPath.length
    }
    
    var hashValue: Int {
        return indexPath.hashValue
    }
    
    func indexPathByAddingIndex(index: Int) -> TreeIndexPath {
        return TreeIndexPath(indexPath: indexPath.indexPathByAddingIndex(index))
    }
}

private func == (lhs: TreeIndexPath, rhs: TreeIndexPath) -> Bool {
    return lhs.indexPath == rhs.indexPath
}
