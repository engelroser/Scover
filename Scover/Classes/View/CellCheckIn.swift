//
//  CellCheckIn.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 27/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class CellCheckIn: UICollectionViewCell {
    
    private let mSep: UIImageView = UIImageView(image: .sep())
    
    private let mIcon: UIImageView = {
        let tmp: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        tmp.backgroundColor = .lightGray
        tmp.contentMode = .scaleAspectFill
        tmp.layer.cornerRadius  = tmp.width/2.0
        tmp.layer.masksToBounds = true
        return tmp
    }()
    
    private let mName:   UILabel = .label(lines: 1)
    private let mCounts: UILabel = .label(lines: 1)
    private let mDesc:   UILabel = .label(font: .light(12.0), lines: 0, color: .hint, alignment: .left)
    private var mImages: [UIImageView] = []
    
    private var mCheckin: Profile.Checkin?
    var checkin: Profile.Checkin? {
        get {
            return mCheckin
        }
        set {
            mCheckin = newValue
            
            mDesc.text = mCheckin?.location?.vicinity
            let f1: UIFont  = .icon(16.3)
            let f2: UIFont  = .regular(10.5)
            let sh: CGFloat = 4.0
            
            let value: NSMutableAttributedString = NSMutableAttributedString(string: Icon.heart.rawValue,
                                                                             attributes: [NSFontAttributeName: f1,
                                                                                          NSForegroundColorAttributeName: UIColor.posRed])
            value.append(NSAttributedString(string: " \(mCheckin?.location?.likes ?? 0)    ", attributes: [NSFontAttributeName: f2,
                                                                                                           NSForegroundColorAttributeName: UIColor.white,
                                                                                                           NSBaselineOffsetAttributeName: sh]))
            value.append(NSAttributedString(string: Icon.time.rawValue, attributes: [NSFontAttributeName: f1,
                                                                                     NSForegroundColorAttributeName: UIColor.white]))
            value.append(NSAttributedString(string: " \(mCheckin?.createdAtObj?.checkinFormat ?? "")", attributes: [NSFontAttributeName: f2,
                                                                                                                    NSForegroundColorAttributeName: UIColor.white,
                                                                                                                    NSBaselineOffsetAttributeName: sh]))
            mCounts.attributedText = value
            mCounts.sizeToFit()
            
            let str: NSMutableAttributedString = NSMutableAttributedString(string: "")
            str.append(NSAttributedString(string: "\(Settings.profile?.firstName ?? "") \(Settings.profile?.lastName ?? "")", attributes: [NSFontAttributeName: UIFont.josefinSansBold(10.5),
                                                                                                                                           NSForegroundColorAttributeName: UIColor.white]))
            str.append(NSAttributedString(string: "WAS_AT".loc, attributes: [NSFontAttributeName: UIFont.regular(10.5),
                                                                             NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.5)]))
            str.append(NSAttributedString(string: mCheckin?.location?.name ?? "", attributes: [NSFontAttributeName: UIFont.josefinSansBold(10.5),
                                                                                               NSForegroundColorAttributeName: UIColor.white]))
            mName.textAlignment  = .left
            mName.attributedText = str
            mName.sizeToFit()
            
            mDesc.text = mCheckin?.location?.vicinity
            
            mIcon.sd_setImage(with: URL(string: Settings.profile?.avatar?.abs ?? ""))
            
            mImages.forEach { (i: UIImageView) in
                i.removeFromSuperview()
            }
            mImages.removeAll()
            for i in 0..<min(mCheckin?.location?.photos.count ?? 0, 3) {
                if let img = mCheckin?.location?.photos[i] {
                    let tmp: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 35.0, height: 35.0))
                    tmp.sd_setImage(with: URL(string: img))
                    tmp.backgroundColor = .lightGray
                    tmp.contentMode = .scaleAspectFill
                    tmp.layer.cornerRadius  = 4.0
                    tmp.layer.masksToBounds = true
                    mImages.append(tmp)
                    addSubview(tmp)
                }
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mSep)
        addSubview(mIcon)
        addSubview(mName)
        addSubview(mDesc)
        addSubview(mCounts)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w: CGFloat = self.width
        let h: CGFloat = self.height
        
        mSep.frame     = CGRect(x: 0, y: h-mSep.height, width: w, height: mSep.height)
        mIcon.origin   = CGPoint(x: 8.0, y: 8.0)
        mName.frame    = CGRect(x: 52.0, y: 11.0, width: w - 52.0 - 10.0, height: 10.0)
        mDesc.frame    = CGRect(x: 52.0, y: 28.0, width: w - 52.0 - 10.0, height: mDesc.font.lineHeight*2.0)
        
        var x: CGFloat = 52.0
        mImages.forEach { (i: UIImageView) in
            i.origin = CGPoint(x: x, y: h - 44.0)
            x = i.maxX + 10.0
        }
        mCounts.origin = CGPoint(x: x, y: h - 26.0 - mCounts.height/2.0)
    }
    
}
