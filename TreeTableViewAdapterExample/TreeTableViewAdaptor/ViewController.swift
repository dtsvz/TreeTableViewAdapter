//
//  ViewController.swift
//  TreeTableViewAdapter
//
//  Created by Dmitriy Tsvetkov on 29.10.16.
//  Copyright © 2016 Dmitriy Tsvetkov. All rights reserved.
//

import UIKit

enum CellIdents: String {
    case ParentCell = "ParentCell"
    case LeafCell = "LeafCell"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var folderAdapter = TreeTableViewAdapter<FolderCellViewModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        folderAdapter.nodes = createModels()
        tableView.reloadData()
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
        for index in 1...10 {
            let folder = FolderCellViewModel(ident: CellIdents.ParentCell.rawValue)
            folder.name = "\(prefix) \(index)"
            result.append(folder)
        }
        return result
    }
    
    @IBAction func openAll(sender: AnyObject) {
        folderAdapter.openAll()
        tableView.reloadData()
    }
    
    @IBAction func closeAll(sender: AnyObject) {
        folderAdapter.closeAll()
        tableView.reloadData()
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return folderAdapter.numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellViewModel = folderAdapter.node(forIndexPath: indexPath),
              let cell = tableView.dequeueReusableCellWithIdentifier(cellViewModel.ident) as? FolderTableViewCell
        else { return cellNotFound() }
        
        cell.folderViewModel = cellViewModel
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cellViewModel = folderAdapter.node(forIndexPath: indexPath) where cellViewModel.hasChildren else { return }
        folderAdapter.changeNodeState(inTableView: tableView, atIndexPath: indexPath)
    }
}
