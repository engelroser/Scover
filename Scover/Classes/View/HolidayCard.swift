//
//  SponsorCard.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/3/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class HolidayCard: UICollectionViewCell {
    
    var block: ((Category)->Void)?

    private struct Dims {
        static let space: CGFloat = 65.0
    }
    
    private let mWrapper: UIView = {
        let tmp: UIView = UIView()
        tmp.backgroundColor = .cardBG
        tmp.layer.cornerRadius = 2.0
        tmp.layer.shouldRasterize = true
        tmp.layer.rasterizationScale = UIScreen.main.scale
        
        tmp.layer.shadowColor   = UIColor.black.cgColor
        tmp.layer.shadowOpacity = 0.5
        tmp.layer.shadowOffset  = CGSize(width: 0, height: 2.0)
        tmp.layer.shadowRadius  = 2
        
        return tmp
    }()
    
    private let mImage: UIImageView = {
        let tmp: UIImageView = UIImageView()
        let layer: CAGradientLayer = CAGradientLayer()
        layer.colors     = [UIColor.white.cgColor, UIColor.clear.cgColor]
        layer.startPoint = CGPoint(x: 0.0, y: 0.3)
        layer.endPoint   = CGPoint(x: 0.0, y: 0.95)
        tmp.layer.mask   = layer;
        tmp.contentMode  = .scaleAspectFill
        tmp.layer.masksToBounds = true
        tmp.layer.cornerRadius  = 2
        return tmp;
    }()
    
    private var mScale: CGFloat = 1.0
    var scale: CGFloat {
        get {
            return mScale
        }
        set {
            mScale = newValue
            let scale: CGFloat = 1.0 - 0.1*mScale
            mWrapper.transform = CGAffineTransform(scaleX: scale, y: scale)
        }
    }
    
    private var mHoliday: Holiday = Holiday()
    var holiday: Holiday {
        get {
            return mHoliday
        }
        set {
            mHoliday = newValue
            mCategories.removeAll()
            mCategories.append(contentsOf: mHoliday.categories)
            
            mTitle.text = mHoliday.name
            mTitle.sizeToFit()
            
            mDate.text  = mHoliday.dateStr()
            mDate.sizeToFit()
            
            if let sponsor = mHoliday.sponsors.first?.name {
                mBottom.text = "SPONSOR_BY".loc+" "+sponsor
            } else {
                mBottom.text = ""
            }
            mBottom.sizeToFit()
            
            mImage.sd_setImage(with: URL(string: mHoliday.backgroundUrl?.abs ?? ""))
            
            mIcons.forEach { (v: Tab) in
                v.removeFromSuperview()
            }
            mIcons.removeAll()
            for i in 0..<min(3, mHoliday.categories.count) {
                let cat: Category = holiday.categories[i]
                let tab: Tab = Tab(title: nil, active: cat.activeUrl?.abs, inactive: cat.inactiveUrl?.abs)
                tab.block = { [weak self, weak cat, weak tab] () -> Void in
                    self?.mIcons.forEach({ (t: Tab) in
                        if t != tab {
                            t.state = .inactive
                        }
                    })
                    if let c = cat, let s = self {
                        s.block?(c)
                    }
                }
                mWrapper.addSubview(tab)
                mIcons.append(tab)
            }
            mIcons.first?.state = .active
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private let mBottom: UILabel = .label(font: .light(7.2), text: "", lines: 1, color: .white, alignment: .left)
    private let mTitle:  UILabel = .label(font: .josefinSansBold(25.0), text: "", lines: 1, color: .white, alignment: .center)
    private let mDate:   UILabel = .label(font: .josefinSansBold(9.0), text: "", lines: 1, color: .white, alignment: .center)
    
    private let mShare:  UILabel = Icon.share.view(size: 17.2, color: .white)
    private let mMark:   UILabel = Icon.bookmark.view(size: 17.2, color: .white)
    
    private var mIcons: [Tab] = []
    
    private var mCategories: [Category] = []
    var category: Category? {
        get {
            if let index = mIcons.index(where: { $0.state == .active }), index < mCategories.count {
                return mCategories[index]
            }
            return nil
        }
        set {
            mCategories.enumerated().forEach { (offset: Int, element: Category) in
                if element.id == newValue?.id && offset < mIcons.count {
                    mIcons[offset].state = .active
                } else if offset < mIcons.count {
                    mIcons[offset].state = .inactive
                }
            }
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mWrapper)
        mWrapper.addSubview(mImage)
        mWrapper.addSubview(mBottom)
        mWrapper.addSubview(mTitle)
        mWrapper.addSubview(mDate)
        mWrapper.addSubview(mShare)
        mWrapper.addSubview(mMark)
        
        mShare.isUserInteractionEnabled = true
        mShare.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doShare)))
        
        mMark.isUserInteractionEnabled = true
        mMark.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doBookmark)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let trans: CGAffineTransform = mWrapper.transform
        mWrapper.transform = .identity
        mWrapper.frame = self.bounds
        mImage.frame   = mWrapper.bounds
        mImage.layer.mask?.frame = mImage.bounds
        mImage.layer.mask  = mImage.layer.mask
        mBottom.origin = CGPoint(x: 23.0, y: mWrapper.height - 18.0 - mBottom.height)
        mTitle.frame   = CGRect(x: 10, y: 28.0 - mTitle.font.lineHeight/2.0, width: mWrapper.width - 20.0, height: mTitle.font.lineHeight)
        mDate.center   = mTitle.center.offset(y: 21.0)
        mShare.center  = CGPoint(x: mWrapper.width - 31.0, y: mWrapper.height - 22.0)
        mMark.center   = mShare.center.offset(x: -73)
        
        var x: CGFloat = (mWrapper.width - CGFloat(mIcons.count-1)*Dims.space)/2.0
        mIcons.forEach { (i: Tab) in
            i.center = CGPoint(x: x, y: mWrapper.height/2.0)
            x += Dims.space
        }

        mWrapper.transform = trans
    }
    
    @objc private func doBookmark() {
        GlobalAction.bookmark(holiday: mHoliday.id)
    }
    
    @objc private func doShare() {
        GlobalAction.share(holiday: mHoliday)
    }
    
}
