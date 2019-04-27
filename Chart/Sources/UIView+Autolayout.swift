//
//  UIView+Autolayout.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/18/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit.UIView

extension UIView {
    func stickToParent() {
        if let parent = self.superview {
            self.translatesAutoresizingMaskIntoConstraints = false
            let width = NSLayoutConstraint(item: self, attribute: .width,relatedBy: .equal,toItem: parent,
                                           attribute: .width, multiplier: 1.0, constant: 0)
            let height = NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal,toItem: parent, attribute: .height, multiplier: 1.0, constant: 0)
            
            let top = NSLayoutConstraint (
                item: self,
                attribute: NSLayoutConstraint.Attribute.top,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: parent,
                attribute: NSLayoutConstraint.Attribute.top,
                multiplier: 1.0,
                constant: 0)
            let leading = NSLayoutConstraint (
                item: self,
                attribute: NSLayoutConstraint.Attribute.leading,
                relatedBy: NSLayoutConstraint.Relation.equal,
                toItem: parent,
                attribute: NSLayoutConstraint.Attribute.leading,
                multiplier: 1.0,
                constant: 0)
            
            parent.addConstraints([width,height,top,leading])
        }
    }
}

