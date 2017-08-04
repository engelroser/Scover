//
//  SectionHeader.swift
//  Scover
//
//  Created by Mobile App Dev on 27/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class SectionHeader: UIView {
    
    private let mCaption: UILabel = {
        let tmp: UILabel = .label(font: .regular(12.0), text: "SHARE".loc, lines: 1, color: .white, alignment: .center)
        tmp.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        return tmp
    }()
    
    private let mLine: UIImageView = UIImageView(image: .sep())
    
    init(name: String?) {
        super.init(frame: .zero)
        mCaption.text = name
        addSubview(mCaption)
        addSubview(mLine)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mCaption.frame = self.bounds
        mLine.frame = CGRect(x: 0, y: self.height - mLine.height, width: self.width, height: mLine.height)
    }
    
}
