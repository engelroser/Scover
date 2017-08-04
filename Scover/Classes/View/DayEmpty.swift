//
//  DayEmpty.swift
//  Scover
//
//  Created by Mobile App Dev on 5/16/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class DayEmpty: UIView {
    
    private let mTop: UILabel = .label(font: .josefinSansBold(20.0), text: "SCOVER".loc, lines: 1, color: .white, alignment: .center)
    private let mBot: UILabel = .label(font: .josefinSansRegular(15.0), text: "FAVOR".loc, lines: 1, color: .white, alignment: .center)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mTop)
        addSubview(mBot)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mTop.center = self.bounds.center()
        mBot.center = mTop.center.offset(y: 18.0)
    }
    
}
