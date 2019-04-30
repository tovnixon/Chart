//
//  UIControl+Bindable.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/28/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import Foundation
import UIKit

extension UITextField: Bindable {
    
    var boundValue: String? {
        get {
            return self.text
        }
        set {
            self.text = newValue
        }
    }
}


