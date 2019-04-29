//
//  AbscissaTableViewCell.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/28/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

class AbscissaTableViewCell: UITableViewCell {

    static let reuseIdentifier = "AbscissaTableViewCell"

    @IBOutlet weak var txtMin: UITextField!

    @IBOutlet weak var lblMin: UILabel!

    @IBOutlet weak var txtStep: UITextField!
    
    @IBOutlet weak var lblStep: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
