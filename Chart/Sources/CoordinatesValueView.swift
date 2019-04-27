//
//  ValueView.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/12/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

class CoordinatesValueView: UIView {
  var xValue: String = ""
  var yValues: [String] = [String]()
  
  var lblX = UILabel(frame: .zero)
  var lblsY = [UILabel]()
  
  var xFont = UIFont.systemFont(ofSize: 19.0)
  var yFont = UIFont.systemFont(ofSize: 17.0)
  
  let horizontalPadding = CGFloat(4)
  let verticalPadding = CGFloat(2)
  let dy = CGFloat(2) // distance between labels by Y
  let dx = CGFloat(10) // distance between labels by X
  
  init(xValue: String, yValues: [String], yColors: [UIColor]) {
    super.init(frame: CGRect.zero)
    
    lblX = UILabel(frame: CGRect.zero)
    lblX.text = xValue
    lblX.font = xFont
    self.addSubview(lblX)
    
    for i in 0..<yValues.count {
      let lbl = UILabel(frame: CGRect.zero)
      lbl.text = yValues[i]
      lbl.font = yFont
      lbl.textColor = yColors[i]
      lblsY.append(lbl)
      self.addSubview(lbl)
    }
    layer.cornerRadius = 4
    backgroundColor = .lightGray
    update(xValue: xValue, yValues: yValues)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  func update(xValue: String, yValues: [String]) {
    lblX.text = xValue
    for i in 0..<yValues.count {
      lblsY[i].text = yValues[i]
    }
    let size = self.calculateSize(xValue: xValue, yValues: yValues)
    let frame = CGRect(x: self.frame.origin.x, y: self.frame.origin.y, width: size.width, height: size.height)
    self.frame = frame
    
  }
  
  private func calculateSize(xValue: String, yValues: [String]) -> CGSize {
    let sizeX = lblX.intrinsicContentSize
    let sizeY = lblsY.map { $0.intrinsicContentSize }.max { size0, size1 in size0.width < size1.width } ?? CGSize.zero
    
    let n = CGFloat(yValues.count)
    let width = 2 * horizontalPadding + sizeX.width + sizeY.width + dx
    let height = 2 * verticalPadding + max(n * sizeY.height + (n + 1) * dy, sizeX.height)
    
    lblX.frame = CGRect(x: horizontalPadding, y: verticalPadding, width: sizeX.width, height: sizeX.height)
    
    for i in 0..<yValues.count {
      let fi = CGFloat(i)
      lblsY[i].frame = CGRect(x: horizontalPadding + dx + sizeX.width, y: verticalPadding + fi * sizeY.height + fi * dy, width: sizeY.width, height: sizeY.height)
    }
    
    return CGSize(width: width, height: height)
  }
}
