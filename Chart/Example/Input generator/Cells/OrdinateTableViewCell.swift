//
//  OrdinateTableViewCell.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/28/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

class OrdinateTableViewCell: UITableViewCell {
    
    static let reuseIdentifier = "OrdinateTableViewCell"
    
    @IBOutlet weak var txtMin: UITextField!
    
    @IBOutlet weak var lblMin: UILabel!
    
    @IBOutlet weak var txtMax: UITextField!
    
    @IBOutlet weak var lblMax: UILabel!
    
    @IBOutlet weak var txtTitle: UITextField!
    
    @IBOutlet weak var colorView: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        lblMin.text = "Min"
        lblMax.text = "Max"
    }
    
    @IBAction func colorSelected() {
        
    }
    
    func bind(_ ordinate: ObservableOrdinate) {
        txtMax.bind(ordinate.max)
        txtMin.bind(ordinate.min)
        txtTitle.bind(ordinate.name)
    }
}
