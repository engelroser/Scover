//
//  IconView.swift
//  Scover
//
//  Created by Mobile App Dev on 09/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class PlaceIcon: UIView {
    
    private let mBackground: UIView = {
        let tmp: UIView = UIView(frame: CGRect(x: 0.0, y: 0.0, width: 33.0, height: 33.0))
        tmp.layer.borderWidth   = 1.0
        tmp.layer.borderColor   = UIColor.white.cgColor
        tmp.backgroundColor     = .gradBot
        tmp.layer.cornerRadius  = tmp.width/2.0
        tmp.layer.masksToBounds = true
        return tmp
    }()
    
    private var mShift: CGFloat = 0.0
    private let mIcon: UIImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mBackground)
        mBackground.addSubview(mIcon)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mBackground.center = self.bounds.center()
        mIcon.frame = mBackground.bounds.insetBy(dx: mShift, dy: mShift)
    }
    
    func attach(place: Place, icon: String?) {
        if let url = icon?.abs {
            mIcon.sd_setImage(with: URL(string: url))
            mBackground.backgroundColor = .gradBot
            mBackground.layer.borderWidth = 1.0
            self.isHidden = false
            mShift = 0.0
        } else if let url = place.icon {
            mIcon.sd_setImage(with: URL(string: url))
            mBackground.backgroundColor = .white
            mBackground.layer.borderWidth = 0.0
            self.isHidden = false
            mShift = 4.0
        } else {
            mIcon.sd_cancelCurrentImageLoad()
            self.isHidden = true
            mIcon.image = nil
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
}
