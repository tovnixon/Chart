//
//  Chart.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/17/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import Foundation
import UIKit

class Chart {
    
    public var dataSource: ChartDataSource
    
    public private(set) var sliderView: SliderView
    
    public private(set) var chartView: PlotView
    
    var startPosition: CGFloat = 0.8
    
    var endPosition: CGFloat = 1.0
    
    var aspectRatio: CGFloat
    
    var offset: CGFloat
    
    init(dataSource: ChartDataSource, chartContainer: inout UIView, sliderContainer: inout UIView) {
        self.dataSource = dataSource
        self.sliderView = SliderView(size: sliderContainer.bounds.size, lenseRelativeWidth: endPosition - startPosition, lenseRelativeOrigin: startPosition)
        self.chartView = PlotView()
        chartView.frame = chartContainer.bounds
        sliderView.frame = sliderContainer.bounds
        
        sliderContainer.addSubview(sliderView)
        chartContainer.addSubview(chartView)
        chartView.stickToParent()
        sliderView.stickToParent()
        
        aspectRatio = 1.0 / (endPosition - startPosition)
        offset = sliderContainer.bounds.size.width * startPosition
        
        sliderView.dataSource = dataSource
        sliderView.delegate = self
        
        chartView.dataSource = dataSource
        
        chartView.intervalChanged(startPosition: startPosition, endPosition: endPosition, movement: .undefined, offset: offset, aspectRatio: aspectRatio)
    }
    
    public func setNeedsLayout() {
        
        sliderView.update()
        aspectRatio = sliderView.bounds.size.width / sliderView.lense.bounds.size.width
        offset = sliderView.bounds.size.width * startPosition
        let f = sliderView.lense.frame
        
        sliderView.lense.frame = CGRect(x: offset, y: f.origin.y, width: f.size.width, height: f.size.height)
        chartView.intervalChanged(startPosition: startPosition, endPosition: endPosition, movement: .undefined, offset: offset, aspectRatio: aspectRatio, animated: true)
        sliderView.updateShadow()
    }
    
    public func selectLine(_ id: Int) -> Bool {
        
        let result = dataSource.selectLine(id)
        sliderView.update()
        chartView.intervalChanged(startPosition: startPosition, endPosition: endPosition, movement: .undefined, offset: offset, aspectRatio: aspectRatio, animated: true)
        return result
    }
}

extension Chart: IntervalChangable {
    
    func movementDidBegin() {
        
    }
    
    func movementDidEnd() {
        
    }
    
    func move(startPosition: CGFloat, endPosition: CGFloat, type: Movement, offset: CGFloat) {
        aspectRatio = sliderView.bounds.size.width / sliderView.lense.bounds.size.width
        self.startPosition = startPosition
        self.endPosition = endPosition
        self.offset = offset
        chartView.intervalChanged(startPosition: startPosition, endPosition: endPosition, movement: type, offset: offset, aspectRatio: aspectRatio, animated: true)
    }
}

