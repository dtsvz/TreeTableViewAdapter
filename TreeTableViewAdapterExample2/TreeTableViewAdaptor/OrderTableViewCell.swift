//
//  OrderTableViewCell.swift
//  TreeTableViewAdaptorExample2
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

class OrderTableViewCell: UITableViewCell {

    @IBOutlet weak var orderNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var stateImageView: UIImageView?
    
    var orderViewModel: OrderCellViewModel? { didSet { fill() } }
    
    func fill() {
        guard let order = orderViewModel else { return }
        stateImageView?.image = nil
        guard order.hasChildren else { return }
        stateImageView?.image = order.opened ? NodeStyles.openedImage : NodeStyles.closedImage
    }
}
