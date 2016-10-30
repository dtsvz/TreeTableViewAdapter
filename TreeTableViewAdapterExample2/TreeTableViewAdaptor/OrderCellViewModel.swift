//
//  OrderCellViewModel.swift
//  TreeTableViewAdaptorExample2
//
//  Created by Dmitriy Tsvetkov on 30.10.16.
//  Copyright © 2016 Dmitriy Tsvetkov. All rights reserved.
//

import UIKit

class OrderCellViewModel: TreeNode {
    typealias T = OrderCellViewModel
    var ident: String
    
    init(ident: String) {
        self.ident = ident
    }
    
    var orderDetails = [OrderCellViewModel]()
    var opened: Bool = false
    var level: Int = 0
    
    var hasChildren: Bool {
        return true
    }
    
    func children<OrderCellViewModel>() -> [OrderCellViewModel] {
        return orderDetails.flatMap { $0 as? OrderCellViewModel }
    }

}


class ProductCellViewModel: OrderCellViewModel {
    
}

class OrderTotalCellViewModel: OrderCellViewModel {

}