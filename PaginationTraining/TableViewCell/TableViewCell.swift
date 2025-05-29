//
//  TableViewCell.swift
//  PaginationTraining
//
//  Created by Pooyan J on 5/29/25.
//

import UIKit

class TableViewCell: UITableViewCell {
    
    static func getHeight() -> CGFloat {
        let eachItemHeight: CGFloat = 44
        let margin = 16
        return (eachItemHeight * 2) + CGFloat(margin * 2)
    }
    
    struct Config {
        var name: String
        var url: String
    }

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var urlLabel: UILabel!
    
}

// MARK: - Setup Functions
extension TableViewCell {
    
    func setup(with config: Config) {
        nameLabel.text = config.name
        urlLabel.text = config.url
    }
}
