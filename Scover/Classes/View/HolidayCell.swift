//
//  HolidayCell.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 4/26/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import SDWebImage

class HolidayCell: CommonCell {
 
    private let mImage: UIImageView = {
        let tmp: UIImageView = UIImageView()
        tmp.contentMode   = .scaleAspectFill
        tmp.clipsToBounds = true
        return tmp
    }()
    private let mLine:  UIImageView = UIImageView(image: .sep())
    private let mOverlay: CAGradientLayer = {
        let tmp: CAGradientLayer = CAGradientLayer()
        tmp.colors     = [UIColor.cellFade.cgColor, UIColor.cellFade.withAlphaComponent(0.0).cgColor]
        tmp.startPoint = CGPoint(x: 0.5, y: 1.0)
        tmp.endPoint   = CGPoint(x: 1.0, y: 1.0)
        return tmp
    }()
    
    private var mIcons: [UIImageView] = []
    
    private let mName: UILabel = .label(font: .josefinSansBold(20), text: "", lines: 2, color: .white, alignment: .left)
    private let mDesc: UILabel = .label(font: .regular(12.0), text: "", lines: 1, color: UIColor.white.withAlphaComponent(0.5), alignment: .left)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.view.addSubview(mImage)
        self.view.layer.addSublayer(mOverlay)
        self.view.addSubview(mLine)
        self.view.addSubview(mName)
        self.view.addSubview(mDesc)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w: CGFloat = self.view.width
        var r: CGFloat = w
        let h: CGFloat = self.view.height
        
        mImage.frame   = self.view.bounds
        mOverlay.frame = mImage.bounds
        mLine.frame    = CGRect(x: 0, y: mImage.maxY-mLine.height, width: w, height: mLine.height)
        
        mIcons.enumerated().forEach { (i: Int, e: UIImageView) in
            e.frame.origin = CGPoint(x: floor(r - e.width - 13.0), y: floor((h - e.height)/2.0))
            r = e.minX
        }
        
        if (mDesc.text?.characters.count ?? 0) > 0 {
            mName.frame = CGRect(x: 15.0, y: 16.0, width: r-30.0, height: mName.font.lineHeight)
            mDesc.frame = CGRect(x: 15.0, y: 38.0, width: r-30.0, height: mDesc.font.lineHeight)
        } else {
            let height: CGFloat = min(mName.text?.heightFor(width: r-30.0, font: mName.font) ?? 0, mName.font.lineHeight*2.0)
            mName.frame = CGRect(x: 15.0, y: (mImage.height - height)/2.0, width: r-30.0, height: height)
        }
    }
    
    func attach(holiday: Holiday) {
        mName.text = holiday.name
        mDesc.text = holiday.description
        mImage.sd_setImage(with: URL(string: holiday.backgroundUrl?.abs ?? ""))
        mIcons.forEach { (v: UIImageView) in
            v.removeFromSuperview()
        }
        mIcons.removeAll()
        for i in 0..<min(3, holiday.categories.count) {
            let tmp: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 44.0, height: 44.0))
            tmp.sd_setImage(with: URL(string: holiday.categories[i].inactiveUrl?.abs ?? ""))
            tmp.layer.cornerRadius = tmp.width/2.0
            tmp.layer.borderWidth = 1.0
            tmp.layer.borderColor = UIColor.white.cgColor
            tmp.backgroundColor = .gradBot
            self.view.addSubview(tmp)
            mIcons.append(tmp)
        }
    }
    
}
