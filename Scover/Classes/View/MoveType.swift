//
//  RouteIcon.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/10/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class MoveType: UIView {
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = CGRect(x: newValue.minX, y: newValue.minY, width: 28.0, height: 28.0)
        }
    }
    
    private var mSelected: Bool = false
    var selected: Bool {
        get {
            return mSelected
        }
        set {
            mSelected = newValue
            self.backgroundColor = newValue ? .gradBot : .clear
        }
    }
    
    private let mIcon: UILabel = .label(font: .icon(15), text: "", lines: 1, color: .white, alignment: .center)
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(with: Icon, target: Any? = nil, action: Selector? = nil) {
        super.init(frame: CGRect(x: 0, y: 0, width: 28.0, height: 28.0))
        mIcon.text = with.rawValue
        addSubview(mIcon)
        self.layer.borderWidth   = 1.0
        self.layer.borderColor   = UIColor.white.cgColor
        self.layer.masksToBounds = true
        self.layer.cornerRadius  = 14.0
        addGestureRecognizer(UITapGestureRecognizer(target: target, action: action))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mIcon.frame = self.bounds
    }
    
}
