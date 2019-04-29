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
    
    init(ordinate: PlotScheme.Ordinate) {
        self.name = Observable<String?>(ordinate.name)
        self.min = Observable<String?>("\(ordinate.min)")
        self.max = Observable<String?>("\(ordinate.max)")
        self.color = Observable<UIColor?>(ordinate.color)
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
    
    init(model: PlotScheme) {
        self.scheme = model
        
        count = Observable<String?>("\(model.count)")
        minX = Observable<String?>("\(model.minX)")
        stepX = Observable<String?>("\(model.stepX)")
        
        count.bind { [unowned self] (value) in
            self.scheme.count = Int(value ?? "0") ?? 0
        }
        
        minX.bind { [unowned self] (value) in
            self.scheme.minX = Int(value ?? "0") ?? 0
        }
        
        stepX.bind { [unowned self] (value) in
            self.scheme.stepX = Int(value ?? "0") ?? 0
        }
        
        var i = 0
        for ordinate in model.ordinates {
            let obsOrd = ObservableOrdinate(ordinate: ordinate)
            bindOrdinateValue(obsOrd, index: i)
            i += 1
            let obsObsOrd = Observable<ObservableOrdinate?>(obsOrd)
            ordinates.append(obsObsOrd)
        }
    }
    
    private func bindOrdinateValue(_ observableOrdinate: ObservableOrdinate, index: Int) {
        observableOrdinate.max.bind { [unowned self] (value) in
            let v = Int(value ?? "0") ?? 0
            if v <= self.scheme.ordinates[index].min {
                // throw validation error to vc?
                //self.ordinates[index].value?.max.value = "\(self.scheme.ordinates[index].max)"
            } else {
                self.scheme.ordinates[index].max = v
            }
        }
        observableOrdinate.min.bind { [unowned self] (value) in
            let v = Int(value ?? "0") ?? 0
            self.scheme.ordinates[index].min = v
        }
        
        observableOrdinate.name.bind { [unowned self] (value) in
            self.scheme.ordinates[index].name = value ?? "Line"
        }
        
        observableOrdinate.color.bind { [unowned self] (value) in
            self.scheme.ordinates[index].color = value ?? .red
        }
    }
    
    private func addObservableOrdinate(_ ordinate: PlotScheme.Ordinate) {
        let obsOrd = ObservableOrdinate(ordinate: ordinate)
        let i = scheme.ordinates.count - 1
        bindOrdinateValue(obsOrd, index: i)
        let obsObsOrd = Observable<ObservableOrdinate?>(obsOrd)
        ordinates.append(obsObsOrd)
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
