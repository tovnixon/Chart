//
//  MathHelper.swift
//  Chart
//
//  Created by Nikita Levintsov on 4/2/19.
//  Copyright © 2019 tovnixon. All rights reserved.
//

import Foundation
import CoreGraphics
import UIKit

class MathHelper {
    
    static func normalizeSlice(array: ArraySlice<Int>, from A: Int, to B: Int, minElement: Int, maxElement: Int) -> [CGFloat] {
        
        let normalizer = CGFloat((B - A)) / CGFloat(maxElement - minElement)
        
        return array.map { CGFloat($0 - minElement) * normalizer + CGFloat(A) }
    }
    
    
    static func normalize(array: [Int], from A: Int, to B: Int, minElement: Int, maxElement: Int) -> [CGFloat] {
        
        let normalizer = CGFloat((B - A)) / CGFloat(maxElement - minElement)
        
        return array.map { CGFloat($0 - minElement) * normalizer + CGFloat(A) }
    }
}

extension CAShapeLayer {
    static func lineShape() -> CAShapeLayer {
        let shape = CAShapeLayer()
        shape.lineCap = .round
        shape.lineJoin = .round
        shape.lineWidth = 1.5
        shape.fillColor = UIColor.clear.cgColor
        shape.isOpaque = true
        return shape
    }
    
    static func textShape(_ text: String) -> CATextLayer {
        let textLayer = CATextLayer()
        textLayer.string = text
        textLayer.fontSize = 12
        textLayer.foregroundColor = UIColor.darkGray.cgColor
        textLayer.isWrapped = true
        textLayer.alignmentMode = CATextLayerAlignmentMode.left
        textLayer.contentsScale = UIScreen.main.scale
        return textLayer
    }
}

extension Array where Element: Comparable {
    
    func localMax(from: Int, to: Int) -> Element? {
        return self.filter(from: from, to: to, comparisonPredicate: { (a, b) -> Bool in a > b })
    }
    
    func localMin(from: Int, to: Int) -> Element? {
        return self.filter(from: from, to: to, comparisonPredicate: { (a, b) -> Bool in a < b })
    }
    
    func filter(from: Int, to: Int, comparisonPredicate: (Element, Element) -> Bool) -> Element? {
        guard from >= 0 && from < self.count &&
            to >= 0 && to < self.count &&
            from <= to else {
                return nil
        }
        
        var max = self[from]
        for i in from..<to {
            if comparisonPredicate(self[i], max) {
                max = self[i]
            }
        }
        return max
    }
    
    func binarySearchOfClosest(to value: Element) -> Int? {
        if let first = self.first, value <= first {
            return 0
        }
        if let last = self.last, value >= last {
            return self.count - 1
        }
        return self.binarySearchOfClosest(to: value, range: 0..<self.count)
    }
    
    private func binarySearchOfClosest(to value: Element, range: Range<Int>) -> Int? {
        guard range.lowerBound <= range.upperBound else {
            return nil
        }
        
        if range.lowerBound == range.upperBound {
            return range.lowerBound
        }
        
        let index = range.lowerBound + (range.upperBound - range.lowerBound) / 2
        if self[index] > value {
            return binarySearchOfClosest(to: value, range: range.lowerBound..<index)
        } else if self[index] < value {
            return binarySearchOfClosest(to: value, range: (index + 1)..<range.upperBound)
        } else {
            return index
        }
    }
}

extension Array where Element: Collection {
    func indexOfLongestElement() -> Int? {
        guard self.count > 0 else {
            return nil
        }
        var longest = self.first!.count
        var indexOfLongest = 0
        for i in 1..<self.count {
            if self[i].count > longest {
                longest = self[i].count
                indexOfLongest = i
            }
        }
        return indexOfLongest
    }
}

extension String {
    func height(withConstrainedWidth width: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: width, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.height)
    }
    
    func width2(withConstrainedHeight height: CGFloat, font: UIFont) -> CGFloat {
        let constraintRect = CGSize(width: .greatestFiniteMagnitude, height: height)
        let boundingBox = self.boundingRect(with: constraintRect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        
        return ceil(boundingBox.width)
    }
}

extension Int {
    func interpolate(x0: Int, x1: Int, y0: Int, y1: Int) -> Int {
        return (y1 - y0) * (self - x0) / (x1 - x0) + y0
    }
}

extension UIColor {
    convenience init(_ rgb: Int32, alpha: CGFloat) {
        let red = CGFloat((rgb & 0xFF0000) >> 16)/256.0
        let green = CGFloat((rgb & 0xFF00) >> 8)/256.0
        let blue = CGFloat(rgb & 0xFF)/256.0
        
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
    convenience init(_ rgb: Int32) {
        self.init(rgb, alpha:1.0)
    }
}
