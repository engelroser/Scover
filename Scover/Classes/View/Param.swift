//
//  Param.swift
//  Scover
//
//  Created by Mobile App Dev on 5/9/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class Param: UIView {
    
    private let mCount: UILabel = .label(font: .josefinSansBold(12.0), text: "", lines: 1, color: .white, alignment: .center)
    private let mName:  UILabel = .label(font: .regular(12.0), text: "", lines: 1, color: .hint, alignment: .center)
    
    var count: String? {
        get {
            return mCount.text
        }
        set {
            mCount.text = newValue
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(name: String) {
        super.init(frame: .zero)
        addSubview(mCount)
        addSubview(mName)
        mName.text = name
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mCount.sizeToFit()
        mName.sizeToFit()
        
        mCount.center = CGPoint(x: width/2.0, y: height/2.0-10)
        mName.center  = mCount.center.offset(y: 20)
    }
    
}
