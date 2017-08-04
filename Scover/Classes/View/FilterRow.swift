//
//  FilterCategory.swift
//  Scover
//
//  Created by Mobile App Dev on 16/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class FilterRow: UIView {
    
    private let mBlock:  (FilterRow)->Void
    private let mTop:    CGFloat
    private let mBot:    CGFloat
    private let mLeft:   CGFloat
    private var mActive: Bool = false
    private var mColor:  UIColor
    var active: Bool {
        get {
            return mActive
        }
        set {
            mActive = newValue
            mName.textColor = mActive ? .white : .bulletOff
            mBullet.backgroundColor = mActive ? mColor : .bulletOff
        }
    }
    
    private let mBullet: UIView = {
        let tmp: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 6.0, height: 6.0))
        tmp.layer.cornerRadius = 3.0
        return tmp
    }()
    
    private lazy var mName: UILabel = .label(font: .josefinSansBold(12.0), text: "", lines: 1, color: .white, alignment: .left)
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            let h: CGFloat = mName.height + mTop + mBot
            super.frame = CGRect(x: newValue.minX, y: newValue.minY, width: ceil(mName.width + mLeft), height: ceil(h))
        }
    }
    
    init(name: String? = "", origin: CGPoint, top: CGFloat = 10, bot: CGFloat = 10, left: CGFloat = 20, color: UIColor, block: @escaping (FilterRow)->Void) {
        mBlock = block
        mTop   = top
        mBot   = bot
        mLeft  = left
        mColor = color
        super.init(frame: .zero)
        
        mName.text = name ?? " "
        mName.sizeToFit()
        addSubview(mName)
        addSubview(mBullet)
        
        self.frame  = CGRect(origin: origin, size: .zero)
        self.active = false
        self.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mName.origin   = CGPoint(x: mLeft, y: mTop)
        mBullet.origin = CGPoint(x: (mLeft-mBullet.width)/2.0, y: floor(mTop + (mName.height - mBullet.height)/2.0))
    }
    
    @objc private func tapped() {
        mBlock(self)
    }
    
}
