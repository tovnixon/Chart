//
//  DisposeBag.swift
//  Chart
//
//  Created by Nikita Levintsov on 5/2/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import Foundation

protocol Disposable {
    
    func disposed(by disposeBag: DisposeBag)
    
    func dispose()
}

final class DisposeBag {
    
    var disposables: [Disposable] = []
    
    func add(_ disposable: Disposable) {
        disposables.append(disposable)
    }
    
    func dispose() {
        for d in disposables {
            d.dispose()
        }
        disposables.removeAll()
    }
}


