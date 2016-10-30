//
//  TreeTableViewAdaptorTests.swift
//  TreeTableViewAdaptorTests
//
//  Created by Dmitriy Tsvetkov on 30.10.16.
//  Copyright © 2016 Dmitriy Tsvetkov. All rights reserved.
//

import XCTest
@testable import TreeTableViewAdaptor

let nodesCount = 10

class TreeTableViewAdaptorTests: XCTestCase {
    
    let firstIndexPath  = NSIndexPath(forRow: 0, inSection: 0)
    let secondIndexPath = NSIndexPath(forRow: 1, inSection: 0)
    let thirdIndexPath  = NSIndexPath(forRow: 2, inSection: 0)
    
    func testFirstLeveRowsCount() {
        let adaptor = adaptorForTest()
        XCTAssertTrue(adaptor.numberOfRows == nodesCount, "Incorrect rows count")
    }
    
    func testOpenCloseState() {
        let adaptor = adaptorForTest()
        adaptor.openAll()
        adaptor.closeAll()
        XCTAssertTrue(adaptor.numberOfRows == nodesCount, "Incorrect rows count")
    }
    
    func testTableViewSection() {
        let adaptor = adaptorForTest()
        let section = 100
        adaptor.tableViewSection = section
        adaptor.nodes.forEach { node in
            let indexPath = adaptor.indexPath { $0 === node }
            XCTAssertTrue(indexPath?.section == section, "Incorrect section index")
        }
    }
    
    func testNodeForIndexPath() {
        let adaptor = adaptorForTest()
        for row in 0..<nodesCount {
            let node = adaptor.node(forIndexPath: NSIndexPath(forRow: row, inSection: 0))
            XCTAssertNotNil(node, "Node not found")
        }

        var node = adaptor.node(forIndexPath: NSIndexPath(forRow: nodesCount, inSection: 0))
        XCTAssertNil(node, "Incorrect node place")
        node = adaptor.node(forIndexPath: NSIndexPath(forRow: 0, inSection: 1))
        XCTAssertNil(node, "Incorrect node place")
        node = adaptor.node(forIndexPath: NSIndexPath(forRow: nodesCount, inSection: 1))
        XCTAssertNil(node, "Incorrect node place")
    }
    
    func testOpenNode() {
        let adaptor = adaptorForTest()
        
        adaptor.openNode(atIndexPath: firstIndexPath)
        XCTAssertTrue(adaptor.numberOfRows == nodesCount * 2, "Incorrect rows count")
        
        var node = adaptor.node(forIndexPath: firstIndexPath)
        XCTAssertTrue(node?.opened ?? false, "Incorrect node state")
        
        adaptor.closeNode(atIndexPath: firstIndexPath)
        XCTAssertTrue(adaptor.numberOfRows == nodesCount, "Incorrect rows count")
        
        node = adaptor.node(forIndexPath: firstIndexPath)
        XCTAssertFalse(node?.opened ?? true, "Incorrect node state")
        
        adaptor.closeAll()
        XCTAssertTrue(adaptor.numberOfRows == nodesCount, "Incorrect rows count")
        
        node = adaptor.node(forIndexPath: firstIndexPath)
        XCTAssertFalse(node?.opened ?? true, "Incorrect node state")
        
        adaptor.openAll()
        XCTAssertTrue(adaptor.numberOfRows == 1110, "Incorrect rows count")
        
        node = adaptor.node(forIndexPath: firstIndexPath)
        XCTAssertTrue(node?.opened ?? false, "Incorrect node state")
    }
    
    func testChangeNodeState() {
        let adaptor = adaptorForTest()
        
        let node = adaptor.node(forIndexPath: firstIndexPath)
        XCTAssertFalse(node?.opened ?? true, "Incorrect node state")
        
        adaptor.changeNodeState(atIndexPath: firstIndexPath)
        XCTAssertTrue(node?.opened ?? false, "Incorrect node state")
        
        adaptor.changeNodeState(atIndexPath: firstIndexPath)
        XCTAssertFalse(node?.opened ?? true, "Incorrect node state")
    }
    
    func testIsNodeOpened() {
        let adaptor = adaptorForTest()
        let firstIndexPath = NSIndexPath(forRow: 0, inSection: 0)
        
        XCTAssertFalse(adaptor.isNodeOpened(atIndexPath: firstIndexPath), "Incorrect node state")
        
        adaptor.changeNodeState(atIndexPath: firstIndexPath)
        XCTAssertTrue(adaptor.isNodeOpened(atIndexPath: firstIndexPath), "Incorrect node state")
        
        adaptor.changeNodeState(atIndexPath: firstIndexPath)
        XCTAssertFalse(adaptor.isNodeOpened(atIndexPath: firstIndexPath), "Incorrect node state")
    }
    
    func testHasChidren() {
        let adaptor = adaptorForTest()
        adaptor.openAll()
        
        XCTAssertTrue(adaptor.hasChildren(firstIndexPath), "Incorrect children state")
        XCTAssertTrue(adaptor.hasChildren(secondIndexPath), "Incorrect children state")
        XCTAssertFalse(adaptor.hasChildren(thirdIndexPath), "Incorrect children state")
    }
    
    func testChildrenIndexPaths() {
        let adaptor = adaptorForTest()
        
        adaptor.openNode(atIndexPath: firstIndexPath)
        var childrenIndexPaths = adaptor.childrenIndexPaths(forIndexPath: firstIndexPath)
        XCTAssertTrue(childrenIndexPaths.count == nodesCount, "Incorrect children count")
        
        adaptor.closeNode(atIndexPath: firstIndexPath)
        childrenIndexPaths = adaptor.childrenIndexPaths(forIndexPath: firstIndexPath)
        XCTAssertTrue(childrenIndexPaths.count == 0, "Incorrect children count")
    }
    
    func testLevel() {
        let adaptor = adaptorForTest()
        adaptor.openAll()
        
        XCTAssertTrue(adaptor.level(forIndexPath: firstIndexPath)  == 1, "Incorrect node level")
        XCTAssertTrue(adaptor.level(forIndexPath: secondIndexPath) == 2, "Incorrect node level")
        XCTAssertTrue(adaptor.level(forIndexPath: thirdIndexPath)  == 3, "Incorrect node level")
    }
    
    func testIndexPathForNode() {
        let adaptor = adaptorForTest()
        adaptor.openAll()
        
        let firstNode = adaptor.node(forIndexPath:  firstIndexPath)
        let secondNode = adaptor.node(forIndexPath: secondIndexPath)
        let thirdNode = adaptor.node(forIndexPath:  thirdIndexPath)
        
        let firstNodeIndexPath  = adaptor.indexPath { $0 === firstNode }
        let secondNodeIndexPath = adaptor.indexPath { $0 === secondNode }
        let thirdNodeIndexPath  = adaptor.indexPath { $0 === thirdNode }
        
        XCTAssertTrue(firstNodeIndexPath  == firstIndexPath,  "Incorrect index path")
        XCTAssertTrue(secondNodeIndexPath == secondIndexPath, "Incorrect index path")
        XCTAssertTrue(thirdNodeIndexPath  == thirdIndexPath,  "Incorrect index path")
    }
}


class FolderCellViewModel: TreeNode {
    typealias T = FolderCellViewModel
    var ident: String
    
    init(ident: String) {
        self.ident = ident
    }
    
    var name: String?
    var subFolders = [FolderCellViewModel]()
    
    var opened: Bool = false
    var level: Int = 0
    
    var hasChildren: Bool {
        return subFolders.count > 0
    }
    
    func children<FolderCellViewModel>() -> [FolderCellViewModel] {
        return subFolders.flatMap { $0 as? FolderCellViewModel }
    }
}

func adaptorForTest() -> TreeTableViewAdaptor<FolderCellViewModel> {
    let adaptor = TreeTableViewAdaptor<FolderCellViewModel>()
    adaptor.nodes = createModels()
    return adaptor
}

func createModels() -> [FolderCellViewModel] {
    var result = [FolderCellViewModel]()
    result.appendContentsOf(folders())
    
    result.forEach {
        $0.subFolders = folders("Sub folder")
        $0.subFolders.forEach {
            $0.subFolders = folders("File")
        }
    }
    
    return result
}

func folders(prefix: String = "Folder")  -> [FolderCellViewModel] {
    var result = [FolderCellViewModel]()
    for index in 1...nodesCount {
        let folder = FolderCellViewModel(ident: "")
        folder.name = "\(prefix) \(index)"
        result.append(folder)
    }
    return result
}