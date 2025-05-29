//
//  TableViewExtension.swift
//  PaginationTraining
//
//  Created by Pooyan J on 5/29/25.
//

import UIKit

extension UITableView {
    
    func register<T: UITableViewCell>(_ cellType: T.Type) {
        register(UINib(nibName: cellType.identifier, bundle: nil), forCellReuseIdentifier: cellType.identifier)
    }
}

extension UITableViewCell {
    
    static var identifier: String {
        String(describing: self)
    }
}
