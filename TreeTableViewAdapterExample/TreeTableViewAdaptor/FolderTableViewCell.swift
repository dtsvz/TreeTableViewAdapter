//
//  FolderTableViewCell.swift
//  TreeTableViewAdaptor
//
//  Created by Dmitriy Tsvetkov on 30.10.16.
//  Copyright © 2016 Dmitriy Tsvetkov. All rights reserved.
//

import UIKit

struct NodeStyles {
    static let parentColor: UIColor = {
        return UIColor.whiteColor()
    }()
    
    static let leafColor: UIColor = {
        return UIColor.whiteColor()
    }()
    
    static let openedImage: UIImage? = {
        return UIImage(named: "li_up")
    }()
    
    static let closedImage: UIImage? = {
        return UIImage(named: "li_down")
    }()
}

class FolderTableViewCell: UITableViewCell {
    var folderViewModel: FolderCellViewModel? { didSet { fill() } }
    
    @IBOutlet weak var labelOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var folderImageView: UIImageView!
    func fill() {
        guard let folder = folderViewModel else { return }
        label?.text = folder.name
        labelOffsetConstraint.constant = CGFloat(folder.level * 16)
        folderImageView.image = nil
        backgroundColor = NodeStyles.leafColor
        
        guard folder.hasChildren else { return }
        backgroundColor = NodeStyles.parentColor
        folderImageView.image = folder.opened ? NodeStyles.openedImage : NodeStyles.closedImage
    }
}
