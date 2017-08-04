//
//  Action.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/9/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class Action: UIView {
    
    private let mIcon:  UILabel = .label(font: .icon(16.4), text: "", lines: 1, color: .white, alignment: .center)
    private let mBack:  UIImageView = UIImageView(image: .actionBG())
    private let mBlock: (Action)->Void
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = CGRect(x: newValue.minX, y: newValue.minY, width: mBack.width, height: mBack.height)
        }
    }
    
    var selected: Bool {
        get {
            return !mBack.isHidden
        }
        set {
            mBack.isHidden = !newValue
            mIcon.alpha = newValue ? 1.0 : 0.5
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(with icon: Icon, bg: Bool = true, color: UIColor = .white, block: @escaping (Action)->Void) {
        mBlock = block
        super.init(frame: CGRect(x: 0, y: 0, width: mBack.width, height: mBack.height))
        addSubview(mBack)
        addSubview(mIcon)
        mIcon.text      = icon.rawValue
        mIcon.textColor = color
        mBack.alpha     = bg ? 1.0 : 0.0
        self.selected   = false
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mIcon.frame = self.bounds
        mBack.frame = self.bounds
    }
    
    @objc private func tapped() {
        mBlock(self)
    }
    
}
