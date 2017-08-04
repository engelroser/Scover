//
//  WelcomePage.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 4/24/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class WelcomePage: UIView {
 
    private let mTitle:  UILabel = .label(font: .josefinSansBold(20.0), text: "WELCOME_TITLE".loc, lines: 1, color: .white, alignment: .center)
    private let mBottom: UILabel = .label(font: .light(12.0), text: "Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque.", lines: 0, color: .hint, alignment: .center)
    
    private let mIcon1: UIImageView = UIImageView(image: .gps())
    private let mIcon2: UIImageView = UIImageView(image: .location())
    
    private let mRoot: UIView = {
        let tmp: UIView = UIView()
        tmp.backgroundColor = .dark
        tmp.layer.cornerRadius  = 2.0
        tmp.layer.masksToBounds = true
        return tmp
    }()
    
    private var mScale: CGFloat = 1.0
    var scale: CGFloat {
        get {
            return mScale
        }
        set {
            mScale = newValue
            let scale: CGFloat = 1.0 - 0.1*mScale
            mRoot.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mRoot)
        mRoot.addSubview(mTitle)
        mRoot.addSubview(mBottom)
        mRoot.addSubview(mIcon1)
        mRoot.addSubview(mIcon2)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let trans: CGAffineTransform = mRoot.transform
        mRoot.transform = .identity
        mRoot.frame     = self.bounds
        
        let w: CGFloat = mRoot.width
        let h: CGFloat = mRoot.height
        mTitle.origin  = CGPoint(x: floor((w - mTitle.width)/2.0), y: floor(h/2.0 - 146.0))
        
        let th: CGFloat = mBottom.text?.heightFor(width: w-20.0, font: mBottom.font) ?? 0
        mBottom.frame   = CGRect(x: 10.0, y: h/2.0 + 156 - th, width: w - 20.0, height: th)
        
        mIcon1.center = CGPoint(x: w/2.0 - 38.0, y: h/2.0 - 34.0)
        mIcon2.center = CGPoint(x: w/2.0 + 38.0, y: h/2.0 - 34.0)
        
        mRoot.transform = trans
    }
    
}
