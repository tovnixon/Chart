//
//  Bind.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/28/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import Foundation

class Observable<T> {
    
    typealias Observer = (T) -> Void
    
    typealias Token = NSObjectProtocol
    
    private var observers = [(Token, Observer)]()
    
    var value: T {
        didSet {
            notify()
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    deinit {
        observers.removeAll()
    }
    
    @discardableResult func bind(_ observer: @escaping Observer) -> Token {
        defer {
            observer(value)
        }
        let object = NSObject()
        observers.append((object, observer))
        return object
    }
    
    func unbind(_ token: Token?) {
        guard let token = token else {
            return
        }
        observers.removeAll { $0.0.isEqual(token) }
    }
    
    private func notify() {
        for (_, observer) in observers {
            observer(value)
        }
    }
}
