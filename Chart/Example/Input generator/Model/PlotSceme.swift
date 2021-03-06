//
//  PlotSceme.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/28/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import Foundation
import UIKit.UIColor

struct PlotScheme {
    
    static var colors: [UIColor] = [.red, .green, .blue, .orange, .purple, .brown, .yellow, .magenta, .cyan]
    
    struct Ordinate {
        
        var name: String = "Line 1"
        
        var min: Int = 0
        
        var max: Int = 100
        
        var color: UIColor = colors[0]
        
        func generateRandom(for count: Int) -> [Int] {
            
            var r = [Int]()
            for _ in 0...count {
                r.append(Int.random(in: min..<max))
            }
            return r
        }
    }
    
    var count: Int = 100
    
    var minX: Int = 1000000000000
    
    var stepX: Int = 100000
    
    var ordinates: [Ordinate] = [Ordinate(name: "Line 1", min: 11, max: 100, color: .red),
                                 Ordinate(name: "Line 2", min: 22, max: 100, color: .green)]
    
    mutating func addOrdinate() -> Ordinate? {
        
        guard ordinates.count < PlotScheme.colors.count else {
            return nil
        }
        var ordinate = Ordinate()
        ordinate.name = "Line \(ordinates.count + 1)"
        ordinate.color = PlotScheme.colors[ordinates.count]
        ordinates.append(ordinate)
        return ordinate
    }
    
    func generateData() -> ChartDataSource {
        
        var x = [Int]()
        for i in 0...count {
            x.append(minX + i * stepX)
        }
        
        var lines = [Line]()
        var id = 0
        for o in ordinates {
            let line = Line(id: id, name: o.name, color: o.color, values: o.generateRandom(for: count))
            lines.append(line)
            id += 1
        }
        return ChartDataSource(x: x, lines: lines)
    }
}

extension PlotScheme {
    var isCountValid: Bool {
        get {
            return count > 0
        }
    }
    
    var isStepXValid: Bool {
        get {
            return stepX > 0
        }
    }
    
    var areOrdinatesValid: Bool {
        get {
            return ordinates.filter { !$0.isValid }.count == 0
        }
    }
    
    var isValid: Bool {
        get {
            return isCountValid && isStepXValid && areOrdinatesValid
        }
    }
}

extension PlotScheme.Ordinate {
    var isValid: Bool {
        return min < max
    }
}
