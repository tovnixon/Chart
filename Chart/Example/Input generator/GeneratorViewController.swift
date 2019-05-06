//
//  GeneratorViewController.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/28/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

private enum Sections: Int {
    case count = 0
    case abscissa = 1
    case ordinates = 2
    
    static var totalValues = 3
}

class GeneratorViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!

    @IBOutlet weak var btnView: UIBarButtonItem!
    
    var disposeBag = DisposeBag()
    
    var viewModel: GeneratorViewModel! {
        didSet {
            bindViewModel()
        }
    }
    
    deinit {
        disposeBag.dispose()
        print("Deinit VC")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.allowsSelection = false
        viewModel.isValid.bind { [unowned self] isValid in
            self.btnView.isEnabled = isValid
        }.disposed(by: disposeBag)
    }
    
    func bindViewModel() {
        guard isViewLoaded else {
            return
        }
    }
    
    @IBAction func viewChart() {
        // segue
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
        case Sections.count.rawValue,
             Sections.abscissa.rawValue:
            return 1
        default:
            return viewModel.ordinates.count
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return Sections.totalValues
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        switch section {
        case Sections.abscissa.rawValue: return "X"
        case Sections.ordinates.rawValue: return "Y"
        default: return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == Sections.ordinates.rawValue {
            return 88
        }
        return 44
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let row = indexPath.row
        let section = indexPath.section
        switch (row, section) {
        case (_, Sections.count.rawValue):
            let cell = tableView.dequeueReusableCell(withIdentifier: CountTableViewCell.reuseIdentifier, for: indexPath) as! CountTableViewCell
            cell.bind(viewModel, disposeBag: disposeBag)
            return cell
        case (_, Sections.abscissa.rawValue):
            let cell = tableView.dequeueReusableCell(withIdentifier: AbscissaTableViewCell.reuseIdentifier, for: indexPath) as! AbscissaTableViewCell
            cell.bind(viewModel, disposeBag: disposeBag)
            return cell
        default:
            let cell = tableView.dequeueReusableCell(withIdentifier: OrdinateTableViewCell.reuseIdentifier, for: indexPath) as! OrdinateTableViewCell
            if let ordinate = viewModel.ordinates[row].value {
                cell.bind(ordinate, disposeBag: disposeBag)
                cell.colorView.layer.cornerRadius = 2
                cell.colorView.backgroundColor = ordinate.color.value
            }
            return cell
        }
    }
}
