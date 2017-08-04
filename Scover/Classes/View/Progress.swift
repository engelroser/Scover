//
//  Progress.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/10/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class Progress: UIView {
    
    private static let center: CGFloat = 8.0
    private static let weight: CGFloat = 1.0
    private static let start:  CGFloat = CGFloat.pi * 1.5
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = CGRect(x: newValue.minX, y: newValue.minY, width: 32.0, height: 32.0)
        }
    }
    
    private var mValue: CGFloat = 0.0
    var progress: CGFloat {
        get {
            return mValue
        }
        set {
            mValue = min(max(newValue, 0.0), 1.0)
            setNeedsDisplay()
        }
    }
    
    private var mColor: UIColor = .greenArc
    var color: UIColor {
        get {
            return mColor
        }
        set {
            mColor = newValue
            setNeedsDisplay()
        }
    }
    
    private let mText: UILabel = UILabel.label(font: .regular(10), text: "", lines: 1, color: .white, alignment: .left)
    var text: String? {
        get {
            return mText.text
        }
        set {
            mText.text = newValue
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(with color: UIColor) {
        super.init(frame: .zero)
        self.backgroundColor = .clear
        self.clearsContextBeforeDrawing = true
        self.addSubview(mText)
        self.color = color
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mText.sizeToFit()
        mText.origin = CGPoint(x: width + 4.0, y: (height - mText.height)/2.0)
    }
    
    override func draw(_ rect: CGRect) {
        if let ctx: CGContext = UIGraphicsGetCurrentContext() {
            
            ctx.saveGState()
            
            let w: CGFloat = self.width
            let h: CGFloat = self.height
            
            ctx.setLineWidth(1.0)
            ctx.setLineJoin(.round)
            
            ctx.setStrokeColor(UIColor.white.withAlphaComponent(0.1).cgColor)
            ctx.strokeEllipse(in: CGRect(x: Progress.weight, y: Progress.weight, width: w - Progress.weight*2.0, height: h - Progress.weight*2.0))
            
            ctx.setStrokeColor(mColor.cgColor)
            ctx.addArc(center: CGPoint(x: w/2.0, y: h/2.0), radius: w/2.0 - Progress.weight, startAngle: Progress.start, endAngle: Progress.start + CGFloat.pi * 2.0 * mValue, clockwise: false)
            ctx.strokePath()
            
            ctx.setFillColor(mColor.cgColor)
            ctx.fillEllipse(in: CGRect(x: (w - Progress.center)/2.0, y: (h - Progress.center)/2.0, width: Progress.center, height: Progress.center))
            
            ctx.restoreGState()
        }
    }
    
}
