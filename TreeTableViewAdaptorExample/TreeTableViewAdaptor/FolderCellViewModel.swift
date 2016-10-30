//
//  FolderCellViewModel.swift
//  TreeTableViewAdaptor
//
//  Created by Dmitriy Tsvetkov on 30.10.16.
//  Copyright © 2016 Dmitriy Tsvetkov. All rights reserved.
//

import UIKit

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
