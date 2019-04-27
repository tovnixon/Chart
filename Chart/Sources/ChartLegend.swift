//
//  ChartLegend.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/10/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import Foundation
import CoreGraphics

class ChartLegend {
  static let meshSizeForXlabels = 7//4
  static let numberOfLabelsbyY = 5
    static let labelXWidth: CGFloat = 60
  static let linehiglhlightCirleRadius = CGFloat(3)
}

struct PlotState {
  let startPosition: CGFloat
  let endPosition: CGFloat
  let maxX: Int
  let maxY: Int
  let aspectRatio: CGFloat
  let offset: CGFloat
  
  public private(set) var offsetX: CGFloat = 0
  
  static let zero = PlotState(startPosition: 0, endPosition: 0, maxX: 0, maxY: 0, aspectRatio: 0, offset: 0)
  
  init(startPosition: CGFloat, endPosition: CGFloat, maxX: Int, maxY: Int, aspectRatio: CGFloat, offset: CGFloat) {
    self.startPosition = startPosition
    self.endPosition = endPosition
    self.maxX = maxX
    self.maxY = maxY
    self.aspectRatio = aspectRatio
    self.offset = offset
    
    self.offsetX = aspectRatio * offset
    
  }
}
