//
//  SliderView.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/2/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import UIKit

class SliderView: UIView, CAAnimationDelegate {
    
    lazy var lense: LenseView = {
        var lenseWidth = bounds.size.width * lenseRelativeWidth
        var lenseOrigin = bounds.size.width * lenseRelativeOrigin
        let lense = LenseView(frame: CGRect(x: lenseOrigin, y: 0, width: lenseWidth, height: bounds.size.height))
        return lense
    }()
    
    private var lenseRelativeWidth: CGFloat = 0.2
    
    private var lenseRelativeOrigin: CGFloat = 0.8
    
    var lineLayers = [Int: CAShapeLayer]()
    
    var shadowLayer = CAShapeLayer()
    
    private var isFirstUpdate: Bool = true
    
    weak var delegate: IntervalChangable?
    
    weak var dataSource: ChartDataSource? {
        didSet {
            self.update()
        }
    }
    
    init(size: CGSize, lenseRelativeWidth: CGFloat, lenseRelativeOrigin: CGFloat) {
        
        super.init(frame: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        self.lenseRelativeWidth = lenseRelativeWidth
        self.lenseRelativeOrigin = lenseRelativeOrigin
        lense.createShape()
        self.addSubview(lense)
        lense.delegate = self
    }
    
    
    convenience init(size: CGSize) {
        self.init(size: size, lenseRelativeWidth: 0.2, lenseRelativeOrigin: 0.8)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadData() {
        update()
    }
    
    func updateShadow() {
        
        let shadowPath = CGMutablePath()
        shadowPath.addRect(CGRect(x: 0, y: lense.dh, width: lense.frame.origin.x, height: self.bounds.size.height - 2 * lense.dh))
        shadowPath.addRect(CGRect(x: lense.frame.maxX, y: lense.dh, width: self.bounds.size.width - lense.frame.maxX, height: self.bounds.size.height - 2 * lense.dh))
        shadowLayer.path = shadowPath
    }
    
    func updatePlots(newCombination: [Int]) {
        
    }
    
    func update() {
        guard let lineDescriptors = dataSource?.getNormalizedData(maxX: Int(bounds.size.width), maxY: Int(bounds.size.height - 2 * lense.dh)) else {
            return
        }
        
        if isFirstUpdate {
            if let activeIds = dataSource?.activeIds {
                for lineId in activeIds {
                    let lineShape = CAShapeLayer.lineShape()
                    lineShape.lineWidth = 1.0
                    lineLayers[lineId] = lineShape
                    lineShape.position = CGPoint(x: lineShape.position.x, y: lineShape.position.y + lense.dh)
                    layer.addSublayer(lineShape)
                    lineLayers[lineId]?.isHidden = false
                }
                self.bringSubviewToFront(lense)
                self.layer.addSublayer(shadowLayer)
                shadowLayer.fillColor = UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.7).cgColor
                shadowLayer.isOpaque = true
                updateShadow()
                
                isFirstUpdate = false
            }
        }
        
        for (layerId, lineLayer) in lineLayers {
            if lineDescriptors.keys.contains(layerId) {
                CATransaction.begin()
                CATransaction.setCompletionBlock({
                    lineLayer.path = lineDescriptors[layerId]?.path
                })
                
                lineLayer.strokeColor = lineDescriptors[layerId]?.color.cgColor
                lineLayer.isHidden = false
                let animation = CABasicAnimation(keyPath: #keyPath(CAShapeLayer.path))
                animation.fillMode = .forwards
                animation.isRemovedOnCompletion = false
                animation.toValue = lineDescriptors[layerId]?.path
                animation.duration = 0.1
                lineLayer.add(animation, forKey: #keyPath(CAShapeLayer.path))
                CATransaction.commit()
            } else {
                lineLayer.isHidden = true
            }
        }
    }
}

extension SliderView: IntervalChangable {
    
    func move(startPosition: CGFloat, endPosition: CGFloat, type: Movement, offset: CGFloat) {
        updateShadow()
        delegate?.move(startPosition: startPosition / bounds.width, endPosition: endPosition / bounds.width, type: type, offset: lense.frame.origin.x)
    }
    
    func movementDidBegin() {
        delegate?.movementDidBegin()
    }
    
    func movementDidEnd() {
        delegate?.movementDidEnd()
    }
}
