//
//  TableViewController.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/27/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let vc = segue.destination as? ChartViewController else {
            return
        }
        switch segue.identifier {
            case "Segue1": vc.dataSource = DataProvider.getDataset2()
            case "Segue2": vc.dataSource = DataProvider.getDataset3()
            case "Segue3": vc.dataSource = DataProvider.getDataset4()
            case "Segue4": vc.dataSource = DataProvider.getDataset5()
            case "Segue5": vc.dataSource = DataProvider.getDataset6()
            case "Segue6": vc.dataSource = DataProvider.getDataset7()
        default: break
        }
    }
    

}
