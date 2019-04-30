//
//  LenseView.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/2/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

enum Movement {
    case slide
    case stretchLeft
    case stretchRight
    case undefined
}

protocol IntervalChangable: class {
    func movementDidBegin()
    func move(startPosition: CGFloat, endPosition: CGFloat, type: Movement, offset:CGFloat)
    func movementDidEnd()
}

extension IntervalChangable {
}

class LenseView: UIView {
    
    var prevTouch: CGPoint = .zero
    
    let dw: CGFloat = 10
    
    let dh: CGFloat = 2
    
    var extraTouchArea: CGFloat
    
    let minWidth: CGFloat
    
    let sliderLayer: CAShapeLayer = CAShapeLayer()
    
    let arrowsLayer: CAShapeLayer = CAShapeLayer()
    
    var borderColor = UIColor(0xcad4dd)
    
    var arrowColor = UIColor.white
    
    var isMoving: Bool = false
    
    weak var delegate: IntervalChangable?
    
    override init(frame: CGRect) {
        self.minWidth = frame.size.width
        self.extraTouchArea = minWidth * 0.2
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateShape() {
        let path = CGMutablePath()
        
        path.addRoundedRect(in: CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.height), cornerWidth: 2, cornerHeight: 2)
        path.addRoundedRect(in: CGRect(x: 0 + dw, y: 0 + dh, width: frame.size.width - dw - dw, height: frame.size.height - dh - dh), cornerWidth: dh, cornerHeight: dh)
        
        let arrowsPath = CGMutablePath()
        // left arrow
        arrowsPath.move(to: CGPoint(x: 0 + dw * 0.75, y: 0 + frame.size.height * 0.33))
        arrowsPath.addLine(to: CGPoint(x: 0 + dw * 0.25, y: 0 + frame.size.height * 0.5))
        arrowsPath.addLine(to: CGPoint(x: 0 + dw * 0.75, y: 0 + frame.size.height * 0.66))
        // right arrow
        arrowsPath.move(to: CGPoint(x: 0 + frame.size.width - dw * 0.75, y: 0 + frame.size.height * 0.33))
        arrowsPath.addLine(to: CGPoint(x: 0 + frame.size.width - dw * 0.25, y: 0 + frame.size.height * 0.5))
        arrowsPath.addLine(to: CGPoint(x: 0 + frame.size.width - dw * 0.75, y: 0 + frame.size.height * 0.66))
        
        sliderLayer.path = path
        arrowsLayer.path = arrowsPath
    }
    
    func createShape() {
        sliderLayer.fillRule = .evenOdd
        sliderLayer.fillColor = borderColor.cgColor
        
        arrowsLayer.lineCap = .round
        arrowsLayer.lineJoin = .round
        arrowsLayer.lineWidth = 2
        arrowsLayer.strokeColor = arrowColor.cgColor
        arrowsLayer.fillColor = UIColor.clear.cgColor
        arrowsLayer.isOpaque = true
        
        sliderLayer.addSublayer(arrowsLayer)
        sliderLayer.isOpaque = true
        self.layer.addSublayer(sliderLayer)
        self.layer.isOpaque = true
        updateShape()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        guard let p = touches.first?.location(in: self.superview), frame.contains(p) else {
            return
        }
        prevTouch = p
        delegate?.movementDidBegin()
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesMoved(touches, with: event)
        // touch is in the target area
        guard let p = touches.first?.location(in: self.superview), frame.contains(p) else {
            return
        }
        var originX = frame.origin.x
        var width = frame.size.width
        let maxX = originX + width
        let dx = p.x - prevTouch.x
        var movementType: Movement = .undefined
        
        defer {
            updateGeometry(newOrigin: originX, newWidth: width, offsetX: dx, movement: movementType)
            prevTouch = p
        }
        
        let deltaTouchX = extraTouchArea + abs(dx)
        switch (p.x, isMoving) {
        case (originX - deltaTouchX..<originX + deltaTouchX, false): // change width by dragging left side
            if originX + dx < 0 {
                return
            }
            // preserve min width
            if width - dx >= minWidth {
                originX += dx
                width -= dx
                movementType = .stretchLeft
            }
        case (maxX - deltaTouchX..<maxX + deltaTouchX, false): // change width by dragging right side
            if originX + width + dx > superview!.bounds.width {
                return
            }
            // preserve min width
            if width + dx >= minWidth {
                width += dx
                movementType = .stretchRight
            }
            
        default: // move with the same width
            if originX + dx < 0 {
                return
            }
            if maxX + dx > superview!.bounds.width {
                return
            }
            originX += dx
            movementType = .slide
            isMoving = true
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        guard let p = touches.first?.location(in: self.superview), frame.contains(p) else {
            return
        }
        prevTouch = p
        isMoving = false
        delegate?.movementDidEnd()
    }
    
    private func updateGeometry(newOrigin: CGFloat, newWidth: CGFloat, offsetX: CGFloat, movement: Movement) {
        frame = CGRect(x: newOrigin, y: frame.origin.y, width: newWidth, height: frame.size.height)
        // only renew the shape if proportions were changed
        if !isMoving {
            updateShape()
        }
        delegate?.move(startPosition: newOrigin, endPosition: frame.maxX, type: movement, offset: offsetX)
    }
}
