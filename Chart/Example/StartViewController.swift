//
//  StartViewController.swift
//  Chart
//
//  Created by Nikita Levintsov on 5/6/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

class StartViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let vc = segue.destination as? GeneratorViewController else {
            return
        }
        
        let scheme = PlotScheme()
        let viewModel = GeneratorViewModel(model: scheme)
        vc.viewModel = viewModel
    }
}
