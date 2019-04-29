//
//  ChartLineTableViewCell.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/26/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

class ChartLineTableViewCell: UITableViewCell {
    static let reuseIdentifier = "ChartLineTableViewCell"
    
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var colorBox: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        colorBox.layer.cornerRadius = 2.0
    }
}
