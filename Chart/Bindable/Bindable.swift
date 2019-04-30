//
//  Bindable.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/28/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import Foundation
import UIKit

fileprivate struct AssociatedKeys {
    static var observable: UInt8 = 0
    static var box: UInt8 = 1
}

internal class Target {
    var onValueChanged: (() -> ())?
    
    @objc func valueChanged() {
        onValueChanged?()
    }
}

protocol Bindable: AnyObject {
    associatedtype BoundType
    var boundValue: BoundType { get set }
}

extension Bindable where Self: NSObjectProtocol {
    private var observable: Observable<BoundType>? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.observable) as? Observable<BoundType>
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.observable, newValue, .OBJC_ASSOCIATION_ASSIGN)
        }
    }
}

extension Bindable where Self: UIControl {
    
    private var target: Target? {
        get {
            return objc_getAssociatedObject(self, &AssociatedKeys.box) as? Target
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.box, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }
    
    func bind(_ observable: Observable<BoundType>) {
        self.observable = observable
        let target = Target()
        self.target = target
        target.onValueChanged = {
            self.observable?.value = self.boundValue
        }
        addTarget(target, action: #selector(Target.valueChanged), for: [.editingChanged, .valueChanged])
        observable.bind { (value) in
            self.boundValue = value
        }
    }
}
