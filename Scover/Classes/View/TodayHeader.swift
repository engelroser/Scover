//
//  TodayHeader.swift
//  Scover
//
//  Created by Mobile App Dev on 4/26/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class TodayHeader: UITableViewHeaderFooterView {
    
    private let mLeft:  UILabel = .label(font: .regular(12), text: "Monday January 2017", lines: 1, color: .white, alignment: .left)
    private let mRight: UILabel = .label(font: .regular(12), text: "5 Holidays", lines: 1, color: .white, alignment: .right)
    
    private let mLine:  UIImageView = UIImageView(image: .sep())
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.backgroundView?.backgroundColor = .cellFade
        self.contentView.backgroundColor = .cellFade
        self.backgroundView = UIView()
        
        addSubview(mLeft)
        addSubview(mRight)
        addSubview(mLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let h: CGFloat = self.height
        let w: CGFloat = self.width
        mLeft.origin   = CGPoint(x: 15.0, y: floor((h - mLeft.height)/2.0))
        mRight.origin  = CGPoint(x: ceil(w - mRight.width - 15.0), y: floor((h - mRight.height)/2.0))
        mLine.frame    = CGRect(x: 0, y: h-mLine.height, width: w, height: mLine.height)
    }
    
    func attach(date: String?, count: UInt) -> Self {
        mLeft.text = date ?? ""
        mLeft.sizeToFit()
        
        mRight.text = count.plura(zero: "NO_HOLIDAYS".loc, one: "HOLIDAY".loc, many: "HOLIDAYS".loc)
        mRight.sizeToFit()
        
        return self
    }
    
}
