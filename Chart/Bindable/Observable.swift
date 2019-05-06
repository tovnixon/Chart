//
//  Bind.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/28/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import Foundation

final class Observable<T> {
    
    typealias Observer = (T) -> Void
    
    typealias Token = NSObjectProtocol
    
    private var observers = [(Token, Observer)]()
    
    private var tokens: [Token] = []
    
    var value: T {
        didSet {
            notify()
        }
    }
    
    init(_ value: T) {
        self.value = value
    }
    
    deinit {
        tokens.removeAll()
        observers.removeAll()
        print("Deinit observable")
    }
    
    @discardableResult func bind(_ observer: @escaping Observer) -> Self {
        defer {
            observer(value)
        }
        let object = NSObject()
        print("bind \(object)")
        observers.append((object, observer))
        tokens.append(object)
        return self
    }
    
    private func unbind(_ token: Token?) {
        guard let token = token else {
            return
        }
        print("unbind \(token)")
        observers.removeAll { $0.0.isEqual(token) }
        tokens.removeAll { $0.isEqual(token) }
    }
    
    func disposed(by disposeBag: DisposeBag) {
        disposeBag.add(self)
    }
    
    private func notify() {
        for (_, observer) in observers {
            observer(value)
        }
    }
}

extension Observable: Disposable {
    
    func dispose() {
        var tokens = Array(self.tokens)
        for token in tokens {
            self.unbind(token)
        }
        tokens.removeAll()
    }
}
