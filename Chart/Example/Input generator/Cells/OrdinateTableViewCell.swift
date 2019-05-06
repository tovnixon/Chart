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
    
    func bind(_ ordinate: ObservableOrdinate, disposeBag: DisposeBag) {
        txtMax.bind(ordinate.max).disposed(by: disposeBag)
        txtMin.bind(ordinate.min).disposed(by: disposeBag)
        txtTitle.bind(ordinate.name).disposed(by: disposeBag)
        
        ordinate.isValid.bind { [unowned self] isValid in
            self.txtMin.layer.borderColor = isValid ? nil : UIColor.red.cgColor
            self.txtMin.layer.borderWidth = isValid ? 0 : 0.5
            self.txtMax.layer.borderColor = isValid ? nil : UIColor.red.cgColor
            self.txtMax.layer.borderWidth = isValid ? 0 : 0.5
        }.disposed(by: disposeBag)

    }
}
