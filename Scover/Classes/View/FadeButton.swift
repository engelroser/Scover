//
//  FadeButton.swift
//  Scover
//
//  Created by Mobile App Dev on 4/17/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class FadeButton: UIView {
    
    private let mLine: UIImageView = UIImageView(image: .sep())
    private let mIcon: UIImageView = UIImageView()
    private let mBG:   UIView  = UIView()
    private let mName: UILabel = {
        let tmp: UILabel = UILabel()
        tmp.font = .regular(14.0) // FONT FIXED
        tmp.textColor = .white
        tmp.textAlignment = .center
        return tmp
    }()
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(name: String = "", icon: UIImage? = nil) {
        super.init(frame: .zero)
        addSubview(mBG)
        addSubview(mLine)
        addSubview(mName)
        addSubview(mIcon)
        
        mBG.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        mName.text  = name
        mIcon.image = icon
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mLine.frame = CGRect(x: 0, y: height - mLine.height, width: width, height: mLine.height)
        mBG.frame   = CGRect(x: 0, y: 0, width: width, height: mLine.minY)
        mName.frame = self.bounds
        
        if let s = mIcon.image?.size {
            mIcon.isHidden = false
            mIcon.frame = CGRect(origin: CGPoint(x: floor(width - 28.0 - s.width), y: floor((height - s.height)/2.0)), size: s)
        } else {
            mIcon.isHidden = true
        }
    }
    
}
