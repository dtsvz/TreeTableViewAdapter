//
//  ViewController.swift
//  TreeTableViewAdapter
//
//  Created by Dmitriy Tsvetkov on 29.10.16.
//  Copyright © 2016 Dmitriy Tsvetkov. All rights reserved.
//

import UIKit

enum CellIdents: String {
    case OrderCell = "OrderCell"
    case ProductCell = "ProductCell"
    case TotalCell = "TotalCell"
}

class ViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var orderAdaptor = TreeTableViewAdapter<OrderCellViewModel>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        orderAdaptor.nodes = createModels()
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = CGFloat(44.0)
        tableView.reloadData()
    }
    
    func createModels() -> [OrderCellViewModel] {
        var result = [OrderCellViewModel]()
        result.appendContentsOf(orders())
        
        return result
    }
    
    func orders(prefix: String = "Folder")  -> [OrderCellViewModel] {
        var result = [OrderCellViewModel]()
        for _ in 1...10 {
            let order = OrderCellViewModel(ident: CellIdents.OrderCell.rawValue)
            order.orderDetails = orderDetails()
            result.append(order)
        }
        return result
    }
    
    func orderDetails() -> [OrderCellViewModel] {
        var result = [OrderCellViewModel]()
        for _ in 1...3 {
            let orderDetail = ProductCellViewModel(ident: CellIdents.ProductCell.rawValue)
            result.append(orderDetail)
        }
        result.append(OrderTotalCellViewModel(ident: CellIdents.TotalCell.rawValue))
        return result
    }
    
    @IBAction func openAll(sender: AnyObject) {
        orderAdaptor.openAll()
        tableView.reloadData()
    }
    
    @IBAction func closeAll(sender: AnyObject) {
        orderAdaptor.closeAll()
        tableView.reloadData()
    }
}


extension ViewController: UITableViewDataSource, UITableViewDelegate {
   
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderAdaptor.numberOfRows
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cellViewModel = orderAdaptor.node(forIndexPath: indexPath),
              let cell = tableView.dequeueReusableCellWithIdentifier(cellViewModel.ident) as? OrderTableViewCell
        else { return cellNotFound() }
        
        cell.orderViewModel = cellViewModel
        
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let cellViewModel = orderAdaptor.node(forIndexPath: indexPath) where cellViewModel.hasChildren else { return }
        orderAdaptor.changeNodeState(inTableView: tableView, atIndexPath: indexPath)
    }
}
