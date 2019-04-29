//
//  GeneratorViewController.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/28/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

class GeneratorViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var viewModel: GeneratorViewModel! {
        didSet {
            bindViewModel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
    }
    
    func bindViewModel() {
        guard isViewLoaded else {
            return
        }
    }
    
    @IBAction func viewChart() {
        
    }
    
    @IBAction func addOrdinate() {
        viewModel.addOrdinate()
        tableView.reloadData()
    }
    
    @IBAction func tap() {
        self.tableView.endEditing(true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ChartViewController else {
            return
        }
        vc.dataSource = viewModel.generateData()
    }
}

extension GeneratorViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
            case 0, 1: return 1
            default: return viewModel.ordinates.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
            case 1: return "X"
            case 2: return "Y"
            default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 88
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = indexPath.row
        let section = indexPath.section
        switch (row, section) {
            case (_, 0):
                let cell = tableView.dequeueReusableCell(withIdentifier: CountTableViewCell.reuseIdentifier, for: indexPath) as! CountTableViewCell
                cell.lblCount.text = "Count"
                cell.txtCount.text = viewModel.count.value
                cell.txtCount.bind(viewModel.count)
                return cell
            case (_, 1):
                let cell = tableView.dequeueReusableCell(withIdentifier: AbscissaTableViewCell.reuseIdentifier, for: indexPath) as! AbscissaTableViewCell
                cell.lblMin.text = "Min"
                cell.lblStep.text = "Step"
                cell.txtMin.text = viewModel.minX.value
                cell.txtStep.text = viewModel.stepX.value
                
                cell.txtMin.bind(viewModel.minX)
                cell.txtStep.bind(viewModel.stepX)
            return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: OrdinateTableViewCell.reuseIdentifier, for: indexPath) as! OrdinateTableViewCell
                let ordinate = viewModel.ordinates[row].value!
                
                cell.lblMin.text = "Min"
                cell.lblMax.text = "Max"
                cell.txtTitle.text = ordinate.name.value
                cell.txtMin.text = "\(ordinate.min.value)"
                cell.txtMax.text = "\(ordinate.max.value)"
                
                cell.colorView.layer.cornerRadius = 2
                cell.colorView.backgroundColor = ordinate.color.value
                
                cell.txtMax.bind(ordinate.max)
                cell.txtMin.bind(ordinate.min)
                cell.txtTitle.bind(ordinate.name)
            
                return cell
        }
    }
}

extension GeneratorViewController: UITableViewDelegate {
    
}
