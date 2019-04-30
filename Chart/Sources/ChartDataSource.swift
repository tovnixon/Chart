//
//  Chart.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/2/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import Foundation
import UIKit.UIColor

struct ChartDescriptor {
    
    var lines = [Int: LineDescriptor]()
    
    var abscises = AxisMarkDescriptor()
    
    var ordinates = AxisMarkDescriptor()
}

struct AxisMarkDescriptor {
    
    var positions = [Int]()
    
    var values = [String]()
    
    var isHidden = [Bool]()
}

struct LineDescriptor {
    
    var path = CGMutablePath()
    
    var color = UIColor.green
    
    var id:Int = 0
}

class Line {
    let y: [Int]
    
    var y_n = [CGFloat]()
    
    let name: String
    
    let color: UIColor
    
    fileprivate let min: Int
    
    fileprivate let max: Int
    
    let id: Int
    
    init(id: Int, name: String, color: UIColor, values: [Int]) {
        self.id = id
        self.name = name
        self.color = color
        y = values
        
        min = y.min() ?? 0
        max = y.max() ?? 0
    }
}

class ChartDataSource {
    public private(set) var activeIds = Set<Int>()
    
    public private(set) var x = [Int]()
    
    var x_n = [CGFloat]()
    
    public private(set) var lines = [Line]()
    
    public private(set) var localMinY = 0
    
    public private(set) var localMaxY = 0
    
    public private(set) var startIndex: Int = 0
    
    public private(set) var endIndex: Int = 0
    
    public private(set) var state = PlotState.zero
    
    private let dateFormatter = DateFormatter()
    
    init(x: [Int], lines: [Line]) {
        self.x = x
        self.lines = lines
        activeIds = Set(lines.map { $0.id })
        
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "MMM dd"
    }
    
    func selectLine(_ id: Int) -> Bool {
        if activeIds.contains(id) {
            if activeIds.count > 1 {
                activeIds.remove(id)
                return false
            } else {
                return true
            }
            
        } else {
            activeIds.insert(id)
            return true
        }
    }
    
    private func getMinAndMax() -> (Int, Int) {
        return getMinAndMax(from: 0, to: x.count - 1)
    }
    
    private func getMinAndMax(from: Int, to: Int) -> (Int, Int) {
        var mins: [Int] = []
        var maxs: [Int] = []
        for id in activeIds {
            for line in lines {
                if id == line.id {
                    mins.append(line.y.localMin(from: from, to: to) ?? 0)
                    maxs.append(line.y.localMax(from: from, to: to) ?? 0)
                }
            }
        }
        return (mins.min() ?? 0, maxs.max() ?? 0)
    }
    
    private func createAbscisDescriptor() -> (Int, Int) {
        
        var skipOrder: Int = 1
        let interval = CGFloat(endIndex - startIndex)
//        let indexStep = ChartLegend.meshSizeForXlabels
        // TODO: Hardcode! - needs initialize maxX before this func is called
        let indexStep = (x.count * 10) / 375 + 1
        let range = CGFloat(x.count) / CGFloat(indexStep)
        
        for i in 0..<indexStep {
            let fi = CGFloat(i)
            if interval > fi * range && interval <= (fi + 1.0) * range {
                skipOrder = Int((i + 1) * indexStep)
                break
            }
        }
        return (indexStep, skipOrder)
    }
}

// MARK: Interpolation

extension ChartDataSource {
    
    /// For initial data
    func getValues(for pos: CGFloat) -> (String, [String], [UIColor])? {
        
        // normalize from x.min to x.max, min = 0, max = maxX
        let a = CGFloat(x.min()!)
        let b = CGFloat(x.max()!)
        let min: CGFloat = x_n.min()!
        let max = x_n.max()!
        
        let renormalizedX = Int((pos - min) * (b - a) / (max - min) + a)
        let date = Date(timeIntervalSince1970: TimeInterval(renormalizedX))
        let strDateX = dateFormatter.string(from: date)
        
        // get index
        guard let index = x_n.binarySearchOfClosest(to: pos) else {
            return nil
        }
        var values = [String]()
        var colors = [UIColor]()
        for lineId in activeIds {
            switch index {
            case 0, x_n.count - 1:
                let renormalizedYString = String(lines[lineId].y[index])
                values.append(renormalizedYString)
                colors.append(lines[lineId].color)
            default:
                if x_n[index] != pos {
                    // x_n[index - 1] < x < x_n[index]
                    let y0 = lines[lineId].y[index - 1]
                    let y1 = lines[lineId].y[index]
                    let x0 = x[index - 1]
                    let x1 = x[index]
                    
                    let renormalizedY = (y1 - y0) * (renormalizedX - x0) / (x1 - x0) + y0
                    let renormalizedYString = String(renormalizedY)
                    values.append(renormalizedYString)
                    colors.append(lines[lineId].color)
                } else {
                    let renormalizedYString = String(lines[lineId].y[index])
                    values.append(renormalizedYString)
                    colors.append(lines[lineId].color)
                }
            }
        }
        return (strDateX, values, colors)
    }
    /// For normalized data
    func getInterpolatedPointsForActiveLinesBetween(p0: CGPoint, p1: CGPoint) -> [Int: CGPoint] {
        var result = [Int: CGPoint]()
        for lineId in activeIds {
            result[lineId] = self.getInterpolatedPointBetween(p0: p0, p1: p1, lineId: lineId)
        }
        return result
    }
    
    func getInterpolatedPointBetween(p0: CGPoint, p1: CGPoint, lineId: Int) -> CGPoint {
        for i in startIndex...endIndex {
            if x_n[i] >= p0.x && x_n[i] <= p1.x {
                return CGPoint(x: x_n[i], y: lines[0].y_n[i])
            }
        }
        let midX = (p0.x + p1.x) * 0.5
        let midY = interpolateYNormalized(x: midX, lineId: lineId)
        
        return midY
    }
    
    func interpolatedYforActiveLines(by x: CGFloat) -> [Int: CGPoint] {
        var result = [Int: CGPoint]()
        for lineId in activeIds {
            result[lineId] = self.interpolateYNormalized(x: x, lineId: lineId)
        }
        return result
    }
    
    func interpolateYNormalized(x: CGFloat, lineId: Int) -> CGPoint {
        guard let index = x_n.binarySearchOfClosest(to: x) else {
            return CGPoint.zero
        }
        switch index {
        case 0,
             x_n.count - 1:
            return CGPoint(x: 0, y:lines[lineId].y_n[index])
        default:
            if x_n[index] != x {
                // x_n[index - 1] < x < x_n[index]
                let y0 = lines[lineId].y_n[index - 1]
                let y1 = lines[lineId].y_n[index]
                let x0 = x_n[index - 1]
                let x1 = x_n[index]
                let y = (y1 - y0) * (x - x0) / (x1 - x0) + y0
                return CGPoint(x: x, y: y)
            } else {
                return CGPoint(x: x, y: lines[lineId].y_n[index])
            }
        }
    }
}

// MARK: Normalization
extension ChartDataSource {
    // Normalization for current interval
    func getNormalizedData(for state: PlotState) -> ChartDescriptor {
        var chart = ChartDescriptor()
        var lineDescriptors = [Int: LineDescriptor]()
        
        self.startIndex = Int(CGFloat(x.count - 1) * state.startPosition)
        self.endIndex = Int(CGFloat(x.count - 1) * state.endPosition)
        let (localMinY, localMaxY) = self.getMinAndMax(from: startIndex, to: endIndex)
        self.localMinY = localMinY
        self.localMaxY = localMaxY
        
        let scaledMaxX = Int(CGFloat(state.maxX) * state.aspectRatio)
        
        self.x_n = MathHelper.normalize(array: x, from: 0, to: scaledMaxX, minElement: x.min()!, maxElement: x.max()!)
        self.x_n = self.x_n.map { $0 - state.offsetX }
        // ordinates <<
        var ordinatesDescriptor = AxisMarkDescriptor()
        let yLabelsCount = ChartLegend.numberOfLabelsbyY
        let yStepValue = CGFloat(localMaxY) / CGFloat(yLabelsCount)
        let yStepPosition = state.maxY / yLabelsCount
        for i in 0..<yLabelsCount {
            ordinatesDescriptor.positions.append(state.maxY - i * yStepPosition)
            ordinatesDescriptor.values.append(String(i * Int(yStepValue)))
        }
        chart.ordinates = ordinatesDescriptor
        // ordinates >>
        
        // abscisses <<
        var abscisDescriptor = AxisMarkDescriptor()
        
        let (indexStep, skipOrder) = self.createAbscisDescriptor()
        for i in 0..<x.count {
            if i % indexStep == 0 {
                abscisDescriptor.positions.append(Int(x_n[i] + ChartLegend.labelXWidth / 2))
                let date = Date(timeIntervalSince1970: TimeInterval(x[i]))
                let strDate = dateFormatter.string(from: date)
                abscisDescriptor.values.append(strDate)
                let shouldHide = i % skipOrder != 0
                abscisDescriptor.isHidden.append(shouldHide)
            }
        }
        
        chart.abscises = abscisDescriptor
        // abscisses >>
        
        for id in activeIds {
            for i in 0..<lines.count {
                let line = lines[i]
                if line.id == id {
                    line.y_n = MathHelper.normalize(array: line.y, from: 0, to: state.maxY, minElement: 0 * localMinY, maxElement: localMaxY)
                    line.y_n = line.y_n.map { CGFloat(state.maxY) - $0 }
                    let p = CGMutablePath()
                    p.move(to: CGPoint(x: x_n[0], y: line.y_n[0]))
                    for k in 1..<x_n.count {
                        p.addLine(to: CGPoint(x: x_n[k], y: line.y_n[k]))
                    }
                    let lineDescriptor = LineDescriptor(path: p, color: line.color, id: line.id)
                    lineDescriptors[line.id] = lineDescriptor
                }
            }
        }
        chart.lines = lineDescriptors
        
        self.state = state
        return chart
    }
    
    /// Normalization for whole array
    func getNormalizedData(maxX: Int, maxY: Int) -> [Int: LineDescriptor] {
        var result = [Int: LineDescriptor]()
        
        let x_n = MathHelper.normalize(array: x, from: 0, to: maxX, minElement: x.min()!, maxElement: x.max()!)
        let (localMinY, localMaxY) = self.getMinAndMax()
        for id in activeIds {
            for line in lines {
                if line.id == id {
                    let y_n = MathHelper.normalize(array: line.y, from: 0, to: maxY, minElement: 0 * localMinY, maxElement: localMaxY)
                    let p = CGMutablePath()
                    p.move(to: CGPoint(x: x_n[0], y: CGFloat(maxY) - y_n[0]))
                    for k in 1..<x_n.count {
                        p.addLine(to: CGPoint(x: x_n[k], y: CGFloat(maxY) - y_n[k]))
                    }
                    let lineDescriptor = LineDescriptor(path: p, color: line.color, id: line.id)
                    result[line.id] = lineDescriptor
                }
            }
        }
        return result
    }
}

