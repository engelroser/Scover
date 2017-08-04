//
//  SectionView.swift
//  Scover
//
//  Created by Mobile App Dev on 5/9/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class SectionView: UICollectionReusableView {

    private var mIcon: UIView?
    private let mName: UILabel = .label(font: .josefinSansBold(15.0), text: "", lines: 1, color: .white, alignment: .center)
    private let mLine: UIView  = UIImageView(image: .sep())
    
    var name: String? {
        get {
            return mName.text
        }
        set {
            mName.text = newValue
        }
    }
    
    var icon: UIView? {
        get {
            return mIcon
        }
        set {
            mIcon?.removeFromSuperview()
            mIcon = newValue
            if let i = mIcon {
                self.addSubview(i)
            }
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        addSubview(mName)
        addSubview(mLine)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mName.frame   = CGRect(x: 0, y: 2, width: width, height: height - 2)
        mIcon?.center = CGPoint(x: 22.0, y: self.height/2.0)
        mLine.frame   = CGRect(x: 0, y: 0, width: width, height: mLine.height)
    }
    
}
