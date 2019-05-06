//
//  GeneratorViewModel.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/29/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import Foundation
import UIKit.UIColor

class ObservableOrdinate {
    
    var name = Observable<String?>("name")
    
    var min = Observable<String?>("0")
    
    var max = Observable<String?>("1")
    
    var color = Observable<UIColor?>(.red)
    
    var isValid: Observable<Bool>
    
    init(ordinate: PlotScheme.Ordinate) {
        self.name = Observable<String?>(ordinate.name)
        self.min = Observable<String?>("\(ordinate.min)")
        self.max = Observable<String?>("\(ordinate.max)")
        self.color = Observable<UIColor?>(ordinate.color)
        self.isValid = Observable<Bool>(ordinate.isValid)
    }
    
    deinit {
        print("ObservableOrdinate deinit")
    }
}

extension PlotScheme.Ordinate {
    init(observable: ObservableOrdinate) {
        self.color = observable.color.value ?? .red
        self.max = Int(observable.max.value ?? "0") ?? 0
        self.min = Int(observable.min.value ?? "0") ?? 0
        self.name = observable.name.value ?? "line N"
    }
}

class GeneratorViewModel {
    
    private var scheme: PlotScheme = PlotScheme()
    
    public private(set) var count: Observable<String?>
    
    public private(set) var minX: Observable<String?>
    
    public private(set) var stepX: Observable<String?>
    
    public private(set) var ordinates = [Observable<ObservableOrdinate?>]()
    
    public private(set) var isCountValid: Observable<Bool>
    
    public private(set) var isStepXValid: Observable<Bool>
    
    public private(set) var isValid: Observable<Bool>
    
    var disposeBag = DisposeBag()
    
    init(model: PlotScheme) {
        self.scheme = model
        
        self.isCountValid = Observable<Bool>(model.isCountValid)
        self.isStepXValid = Observable<Bool>(model.isStepXValid)
        self.isValid = Observable<Bool>(model.isValid)
        
        count = Observable<String?>("\(model.count)")
        minX = Observable<String?>("\(model.minX)")
        stepX = Observable<String?>("\(model.stepX)")
        
        isStepXValid.bind { [unowned self] _ in
            self.isValid.value = self.scheme.isValid
        }.disposed(by: disposeBag)
        
        isCountValid.bind { [unowned self] _ in
            self.isValid.value = self.scheme.isValid
        }.disposed(by: disposeBag)
        
        count.bind { [unowned self] (value) in
            self.scheme.count = Int(value ?? "0") ?? 0
            self.isCountValid.value = self.scheme.isCountValid
        }.disposed(by: disposeBag)
        
        minX.bind { [unowned self] (value) in
            self.scheme.minX = Int(value ?? "0") ?? 0
        }.disposed(by: disposeBag)
        
        stepX.bind { [unowned self] (value) in
            self.scheme.stepX = Int(value ?? "0") ?? 0
            self.isStepXValid.value = self.scheme.isStepXValid
        }.disposed(by: disposeBag)
        
        var i = 0
        for ordinate in model.ordinates {
            let obsOrd = ObservableOrdinate(ordinate: ordinate)
            let obsObsOrd = Observable<ObservableOrdinate?>(obsOrd)
            ordinates.append(obsObsOrd)
            bindOrdinateValue(obsOrd, index: i)
            i += 1
        }
    }
    
    deinit {
        disposeBag.dispose()
        print("Deinit ViewModel")
    }
    
    private func bindOrdinateValue(_ observableOrdinate: ObservableOrdinate, index: Int) {
        observableOrdinate.max.bind { [unowned self] (value) in
            self.scheme.ordinates[index].max = Int(value ?? "0") ?? 0
            self.ordinates[index].value?.isValid.value = self.scheme.ordinates[index].isValid
        }.disposed(by: disposeBag)
        observableOrdinate.min.bind { [unowned self] (value) in
            self.scheme.ordinates[index].min = Int(value ?? "0") ?? 0
            self.ordinates[index].value?.isValid.value = self.scheme.ordinates[index].isValid
        }.disposed(by: disposeBag)
        
        observableOrdinate.name.bind { [unowned self] (value) in
            self.scheme.ordinates[index].name = value ?? "Line"
        }.disposed(by: disposeBag)
        
        observableOrdinate.color.bind { [unowned self] (value) in
            self.scheme.ordinates[index].color = value ?? .red
        }.disposed(by: disposeBag)
        
        self.ordinates[index].value?.isValid.bind({ [unowned self] _ in
            self.isValid.value = self.scheme.isValid
        }).disposed(by: disposeBag)
    }
    
    private func addObservableOrdinate(_ ordinate: PlotScheme.Ordinate) {
        let obsOrd = ObservableOrdinate(ordinate: ordinate)
        let obsObsOrd = Observable<ObservableOrdinate?>(obsOrd)
        let i = scheme.ordinates.count - 1
        ordinates.append(obsObsOrd)
        bindOrdinateValue(obsOrd, index: i)
    }
    
    // MARK: In  <<=
    func addOrdinate() {
        if let ordinate = scheme.addOrdinate() {
            addObservableOrdinate(ordinate)
        }
    }
    
    // MARK: Out =>>
    func generateData() -> ChartDataSource {
        return scheme.generateData()
    }
}
