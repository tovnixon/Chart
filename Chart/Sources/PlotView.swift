//
//  PlotView.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/6/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

class PlotView: UIView {
  private var isFirstUpdate: Bool = true
  private let xLabelsHeight: CGFloat = 40
  private let yLabelsOffset: CGFloat = 10
  private var yAxisesLayers = [CAShapeLayer]()
  
  /// Highlight selected values
  private var pointers = [Int: CAShapeLayer]()
  private var prevTouches = [Int: CGPoint]()
  private var prevPureTouch = CGPoint.zero
  private var verticalLine = CAShapeLayer()
  private var isTouched = false
  private var legend: CoordinatesValueView?
  
  weak var dataSource: ChartDataSource?  {
    didSet {
   //   update()
    }
  }
  var lineLayers = [Int: CAShapeLayer]()
  var abscisLayers = [CATextLayer]()
  var ordinateLayers = [CATextLayer]()
  
  func reloadData() {
  }
  
  override func draw(_ rect: CGRect) {
    super.draw(rect)
    
  }
  
  func intervalChanged(startPosition: CGFloat, endPosition: CGFloat, movement: Movement, offset: CGFloat, aspectRatio: CGFloat, animated: Bool = false) {

    let plotState = PlotState(startPosition: startPosition, endPosition: endPosition, maxX: Int(bounds.size.width), maxY: Int(bounds.size.height - xLabelsHeight), aspectRatio: aspectRatio, offset: offset)
    
    guard let chart = dataSource?.getNormalizedData(for: plotState) else {
      return
    }
    
    if isFirstUpdate {
      layer.masksToBounds = true
      
      let linePath = CGMutablePath()
      linePath.move(to: CGPoint(x: 0, y: 0))
      linePath.addLine(to: CGPoint(x: 0, y: bounds.size.height - xLabelsHeight))
      verticalLine.path = linePath
      verticalLine.strokeColor = UIColor.gray.cgColor
      verticalLine.lineWidth = 0.5
      verticalLine.isHidden = !isTouched
      layer.addSublayer(verticalLine)
      
      // chart lines
      if let activeIds = dataSource?.activeIds {
        for lineId in activeIds {
          let lineShape = CAShapeLayer.lineShape()
          lineLayers[lineId] = lineShape
          layer.addSublayer(lineShape)
          lineLayers[lineId]?.isHidden = false
          
          // pointer
          let linePointer = CAShapeLayer()
          let c = CGPath(ellipseIn: CGRect(x: 0, y: 0, width: 2 * ChartLegend.linehiglhlightCirleRadius, height: 2 * ChartLegend.linehiglhlightCirleRadius), transform: nil)
          linePointer.path = c
          linePointer.strokeColor = dataSource!.lines[lineId].color.cgColor
          linePointer.fillColor = UIColor.white.cgColor // same as plot background!
          linePointer.lineWidth = 1.5
          linePointer.isHidden = !isTouched
          pointers[lineId] = linePointer
          layer.addSublayer(linePointer)
          // initialize pointers prev. touch
          prevTouches[lineId] = CGPoint.zero
        }
        isFirstUpdate = false
      }
      // abscis marks
      for i in 0..<chart.abscises.positions.count {
        let pos = chart.abscises.positions[i]
        let value = chart.abscises.values[i]
        let abscisLayer = CAShapeLayer.textShape(value)
        abscisLayer.frame = CGRect(x: CGFloat(pos), y: bounds.size.height - xLabelsHeight, width: ChartLegend.labelXWidth, height: xLabelsHeight)
        abscisLayer.isHidden = chart.abscises.isHidden[i]
        abscisLayers.append(abscisLayer)
        layer.addSublayer(abscisLayer)
      }
      
      // ordinates marks
      for i in 0..<chart.ordinates.positions.count {
        // labels
        let pos = chart.ordinates.positions[i]
        let value = chart.ordinates.values[i]
        let ordinateLayer = CAShapeLayer.textShape(value)
        ordinateLayer.frame = CGRect(x: Int(yLabelsOffset), y: pos - Int(xLabelsHeight), width: Int(ChartLegend.labelXWidth), height: Int(xLabelsHeight))
        ordinateLayers.append(ordinateLayer)
        layer.addSublayer(ordinateLayer)
        
        // horizontal lines
        let lineLayer = CAShapeLayer()
        let path = CGMutablePath()
        path.move(to: CGPoint(x: Int(yLabelsOffset), y: pos))
        path.addLine(to: CGPoint(x: Int(bounds.size.width - yLabelsOffset), y: pos))
        lineLayer.path = path
        lineLayer.lineWidth = 0.5
        lineLayer.strokeColor = UIColor.gray.cgColor
        yAxisesLayers.append(lineLayer)
        layer.addSublayer(lineLayer)
      }

    }
    
    // chart lines
    for (layerId, lineLayer) in lineLayers {
      if chart.lines.keys.contains(layerId) {
        if animated {
          CATransaction.begin()
          CATransaction.setCompletionBlock({
            lineLayer.path = chart.lines[layerId]?.path
          })
          
          lineLayer.strokeColor = chart.lines[layerId]?.color.cgColor
          lineLayer.isHidden = false
          let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
          animation.fillMode = .forwards
          animation.isRemovedOnCompletion = false
          animation.toValue = chart.lines[layerId]?.path
          animation.duration = 0.1
          lineLayer.add(animation, forKey: #keyPath(CAShapeLayer.path))
          CATransaction.commit()
        } else {
          lineLayer.path = chart.lines[layerId]?.path
          lineLayer.strokeColor = chart.lines[layerId]?.color.cgColor
          lineLayer.removeAllAnimations()
          lineLayer.isHidden = false
        }
      } else {
        lineLayer.isHidden = true
      }
    }
    
    // abscis marks
    for i in 0..<abscisLayers.count {
      let isHidden = chart.abscises.isHidden[i]
      let abscisLayer = abscisLayers[i]
      abscisLayer.string = chart.abscises.values[i]
      //abscisLayer.position = CGPoint(x: CGFloat(chart.abscises.positions[i]), y: abscisLayer.position.y)
      abscisLayer.isHidden = isHidden
      
      let lineAnimation = CAKeyframeAnimation(keyPath: "position.x")
      lineAnimation.values = [CGFloat(chart.abscises.positions[i])]
      lineAnimation.duration = 0.1
      lineAnimation.isRemovedOnCompletion = false
      lineAnimation.fillMode = .forwards
      abscisLayer.add(lineAnimation, forKey: "move1")
    }
    
    // ordinates marks
    for i in 0..<ordinateLayers.count {
      let ordinateLayer = ordinateLayers[i]
      ordinateLayer.string = chart.ordinates.values[i]
      ordinateLayer.position = CGPoint(x: ordinateLayer.position.x, y: CGFloat(chart.ordinates.positions[i]))
    }
  }
}

/// Highlight selected values
extension PlotView {
  
  override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesBegan(touches, with: event)
    isTouched = true
    guard let p = touches.first?.location(in: self), frame.contains(p) else {
      return
    }
    
    for (lineId, pointerShape) in pointers {
      if dataSource!.activeIds.contains(lineId) {
        pointerShape.isHidden = !isTouched
      }
    }
    verticalLine.isHidden = !isTouched
    verticalLine.position = CGPoint(x: p.x, y: verticalLine.position.y)
    prevTouches = dataSource!.interpolatedYforActiveLines(by: p.x)
    prevPureTouch = p
    
    
    if self.legend == nil, let (valueX, valuesY, colorsY) = dataSource?.getValues(for: p.x) {
      self.legend = CoordinatesValueView(xValue: valueX, yValues: valuesY, yColors: colorsY)
      self.addSubview(legend!)
      legend?.center = CGPoint(x: p.x, y: xLabelsHeight)
      
    }
    calculateHighlighted(p: p)
  }
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
    super.touchesMoved(touches, with: event)
    // touch is in the target area
    guard let p = touches.first?.location(in: self), frame.contains(p) else {
      return
    }
    calculateHighlighted(p: p)
    prevPureTouch = p
  }
  
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesCancelled(touches, with: event)
        self.touchesEnded(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        isTouched = false
        for (_, pointerShape) in pointers {
            pointerShape.isHidden = !isTouched
        }
        verticalLine.isHidden = !isTouched
        self.legend!.removeFromSuperview()
        self.legend = nil

        if let p = touches.first?.location(in: self.superview), frame.contains(p) {
            verticalLine.position = CGPoint(x: p.x, y: verticalLine.position.y)
            prevTouches = dataSource!.interpolatedYforActiveLines(by: p.x)
            prevPureTouch = p
        }
    }
  
  private func calculateHighlighted(p: CGPoint) {
    let pointsBetween = dataSource!.getInterpolatedPointsForActiveLinesBetween(p0: prevPureTouch, p1: p)
    let currentTouches = dataSource!.interpolatedYforActiveLines(by: p.x)
    
    // move circles along lines
    let offset = -ChartLegend.linehiglhlightCirleRadius
    for (lineId, pointerShape) in pointers {
      if dataSource?.activeIds.contains(lineId) ?? false {
        let animation = CAKeyframeAnimation(keyPath: "position")
        animation.values = [CGPoint(x: prevTouches[lineId]!.x + offset, y: prevTouches[lineId]!.y + offset),
                            CGPoint(x: pointsBetween[lineId]!.x + offset, y: pointsBetween[lineId]!.y + offset),
                            CGPoint(x: currentTouches[lineId]!.x + offset, y: currentTouches[lineId]!.y + offset)]
        animation.duration = 0.3
        animation.isRemovedOnCompletion = false
        animation.fillMode = .forwards
        pointerShape.add(animation, forKey: "move")
      }
    }
    
    // move vertical line
    let lineAnimation = CAKeyframeAnimation(keyPath: "position.x")
    lineAnimation.values = [p.x]
    lineAnimation.duration = 0.3
    lineAnimation.isRemovedOnCompletion = false
    lineAnimation.fillMode = .forwards
    verticalLine.add(lineAnimation, forKey: "move1")
    
    if let (valueX, valuesY, _) = dataSource?.getValues(for: p.x) {
      legend?.update(xValue: valueX, yValues: valuesY)
    }

    // keep legend view in bounds
    let leftEdge = legend!.bounds.size.width * 0.5
    let rightEdge = frame.size.width - leftEdge
    switch p.x {
    case 0...leftEdge:
      self.legend!.center.x = leftEdge
    case rightEdge...frame.size.width:
      self.legend!.center.x = rightEdge
    default:
      self.legend!.center.x = p.x
    }
    prevTouches = currentTouches
  }
}
