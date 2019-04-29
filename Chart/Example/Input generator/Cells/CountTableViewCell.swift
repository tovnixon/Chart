//
//  CountTableViewCell.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/28/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

class CountTableViewCell: UITableViewCell, UITextFieldDelegate {
    static let reuseIdentifier = "CountTableViewCell"
    
    @IBOutlet weak var txtCount: UITextField!
    @IBOutlet weak var lblCount: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
 
    func textFieldDidEndEditing(_ textField: UITextField) {
        print("sd")
    }
}

