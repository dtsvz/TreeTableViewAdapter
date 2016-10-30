//
//  Helpers.swift
//  TreeTableViewAdaptor
//
//  Created by Dmitriy Tsvetkov on 30.10.16.
//  Copyright © 2016 Dmitriy Tsvetkov. All rights reserved.
//

import UIKit

func cellNotFound(cellIdent: String = "unknown") -> UITableViewCell {
    let cell = UITableViewCell()
    cell.textLabel?.text = "Cell with ident \"\(cellIdent)\" was not found"
    cell.backgroundColor = UIColor.redColor()
    return cell
}
