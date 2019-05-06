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
        lblMin.text = "Min"
        lblStep.text = "Step"
    }
    
    func bind(_ viewModel: GeneratorViewModel) {
        txtMin.bind(viewModel.minX)
        txtStep.bind(viewModel.stepX)
        
        viewModel.isStepXValid.bind { [unowned self] isValid in
            self.txtStep.layer.borderColor = isValid ? nil : UIColor.red.cgColor
            self.txtStep.layer.borderWidth = isValid ? 0 : 0.5
        }
    }
}
