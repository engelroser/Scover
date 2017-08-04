//
//  LoginWith.swift
//  Scover
//
//  Created by Mobile App Dev on 4/17/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class LoginWith: UIView {
    
    private let mImage: UIImageView = UIImageView()
    private let mTitle: UILabel = {
        let tmp: UILabel = UILabel()
        tmp.numberOfLines = 1
        tmp.textColor = .white
        tmp.font = .light(13.0) // FONT FIXED
        return tmp
    }()
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(name: String, icon: UIImage) {
        super.init(frame: .zero)
        addSubview(mImage)
        addSubview(mTitle)
        
        mImage.image = icon
        mImage.frame.size = mImage.image?.size ?? .zero
        
        mTitle.text  = name
        mTitle.sizeToFit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mImage.frame.origin   = CGPoint(x: 0, y: floor((self.height - mImage.height)/2.0))
        mTitle.frame.origin   = CGPoint(x: ceil(mImage.maxX + 22.0), y: floor((self.height - mTitle.height)/2.0))
        self.frame.size.width = mTitle.maxX
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return mImage.point(inside: mImage.convert(point, from: self), with: event) || mTitle.point(inside: mTitle.convert(point, from: self), with: event)
    }
    
}
