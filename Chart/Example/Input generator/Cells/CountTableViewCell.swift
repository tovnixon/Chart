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
        lblCount.text = "Count"
    }
    
    func bind(_ viewModel: GeneratorViewModel, disposeBag: DisposeBag) {
        
        txtCount.bind(viewModel.count).disposed(by: disposeBag)
        
        viewModel.isCountValid.bind { [unowned self] isValid in
            self.txtCount.layer.borderColor = isValid ? nil : UIColor.red.cgColor
            self.txtCount.layer.borderWidth = isValid ? 0 : 0.5
        }.disposed(by: disposeBag)
    }
}

