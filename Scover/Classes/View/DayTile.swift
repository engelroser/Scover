//
//  DayTile.swift
//  Scover
//
//  Created by Mobile App Dev on 5/15/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class DayTile: UIView {
    
    private let mImage: UIImageView = {
        let tmp: UIImageView = UIImageView()
        tmp.alpha = 0.2
        return tmp
    }()
    
    private let mText: UILabel = .label(font: .josefinSansBold(13.0), text: "", lines: 2, color: .white, alignment: .center)
    
    private let mButton: UIButton = {
        let tmp: UIButton = UIButton(type: .custom)
        tmp.frame = CGRect(x: 0, y: 0, width: 90.0, height: 23.0)
        tmp.setTitleColor(.white, for: .normal)
        tmp.layer.borderWidth = 1.0
        tmp.layer.borderColor = UIColor.white.cgColor
        tmp.titleLabel?.font  = .regular(10.0)
        tmp.isUserInteractionEnabled = false
        return tmp
    }()
    
    private var mBlock: ()->Void
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(count: Int, image: String, date: Date?, block: @escaping ()->Void) {
        mBlock =  block
        super.init(frame: .zero)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        
        mButton.setTitle("\(count) " + (count == 1 ? "HOLIDAY".loc : "HOLIDAYS".loc), for: .normal)
        mImage.sd_setImage(with: URL(string: image))
        if let d = date {
            mText.text = d.tileFormat
            mText.sizeToFit()
        }
        
        addSubview(mImage)
        addSubview(mText)
        addSubview(mButton)
    }
    
    @objc private func tapped() {
        mBlock()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mImage.frame = self.bounds
        mText.sizeToFit()
        
        let y: CGFloat = floor((self.height - mButton.height - 12.0 - mText.height)/2.0)
        mText.origin   = CGPoint(x: floor((self.width - mText.width)/2.0), y: y)
        mButton.origin = CGPoint(x: floor((self.width - mButton.width)/2.0), y: mText.maxY + 12.0)
    }
    
}
