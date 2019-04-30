//
//  ChartViewController.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/18/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

class ChartViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var chartContainer: UIView!
    
    @IBOutlet weak var sliderContainer: UIView!
    
    var chart: Chart!
    
    var dataSource: ChartDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        guard let dataSource = self.dataSource else {
            assertionFailure("Chart data source is not initialized")
            return
        }
        self.chart = Chart(dataSource: dataSource, chartContainer: &chartContainer, sliderContainer: &sliderContainer)
        
        tableView.backgroundView?.backgroundColor = .white
        tableView.backgroundColor = .white
        tableView.isScrollEnabled = false
    }
}

extension ChartViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return chart!.dataSource.lines.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChartLineTableViewCell.reuseIdentifier, for: indexPath) as! ChartLineTableViewCell
        
        let line = chart!.dataSource.lines[indexPath.row]
        cell.colorBox.backgroundColor = line.color
        cell.title.text = line.name
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let line = chart!.dataSource.lines[indexPath.row]
        if let cell = tableView.cellForRow(at: indexPath) {
            let isSelected = chart.selectLine(line.id)
            cell.accessoryType = isSelected ? .checkmark : .none
        }
    }
}
