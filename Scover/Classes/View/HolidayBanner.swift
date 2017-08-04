//
//  LocationBanner.swift
//  Scover
//
//  Created by Mobile App Dev on 5/5/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class HolidayBanner: UIView {
    
    private struct Dims {
        
        static let icons: CGFloat = 60.0
        
    }

    private let mBG: UIView = {
        let tmp: UIView = UIView()
        tmp.backgroundColor = .cardBG
        return tmp
    }()
    
    private let mImg: UIImageView = {
        let tmp: UIImageView = UIImageView()
        let layer: CAGradientLayer = CAGradientLayer()
        layer.colors      = [UIColor.white.cgColor, UIColor.white.withAlphaComponent(0.0).cgColor]
        layer.startPoint  = CGPoint(x: 0.0, y: 0.0)
        layer.endPoint    = CGPoint(x: 0.0, y: 0.85)
        tmp.layer.mask    = layer
        tmp.contentMode   = .scaleAspectFill
        tmp.clipsToBounds = true
        return tmp
    }()
    
    private lazy var mLogo: UIImageView = { [weak self] in
        let tmp: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 46, height: 46))
        tmp.contentMode = .scaleAspectFill
        tmp.clipsToBounds = true
        tmp.layer.cornerRadius = tmp.width/2.0
        tmp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(logoTapped)))
        tmp.isUserInteractionEnabled = true
        return tmp
    }()
    private let mSep:   UIImageView = UIImageView(image: .sep())
    private let mTop:   UILabel     = .label(font: .josefinSansBold(25.0), text: "", lines: 0, color: .white, alignment: .center)
    private let mMid:   UILabel     = .label(font: .regular(9.0), text: "", lines: 0, color: .white, alignment: .center)
    private var mIcons: [Tab]       = []
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = CGRect(x: newValue.minX, y: newValue.minY, width: newValue.width, height: max(minHeight(for: newValue.width), newValue.height))
        }
    }
    
    private let mBlock: (()->Void)?
    
    var selected: Int? {
        return mIcons.index(where: { $0.state == .active })
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    private let mHoliday: Holiday
    
    init(with holiday: Holiday, block: (()->Void)? = nil) {
        mBlock   = block
        mHoliday = holiday
        super.init(frame: .zero)
        addSubview(mBG)
        addSubview(mImg)
        addSubview(mSep)
        addSubview(mTop)
        addSubview(mMid)
        addSubview(mLogo)
        
        if let img = holiday.sponsors.first?.logoUrl?.abs {
            mLogo.sd_setImage(with: URL(string: img))
        } else {
            mLogo.isHidden = true
        }
        
        mTop.text = holiday.name
        mMid.text = holiday.description
        mImg.sd_setImage(with: URL(string: holiday.bannerUrl?.abs ?? ""))
        
        for i in 0..<min(4, holiday.categories.count) {
            let cat: Category = holiday.categories[i]
            let tab: Tab = Tab(title: cat.name ?? "", active: cat.activeUrl?.abs, inactive: cat.inactiveUrl?.abs)
            tab.block = { [weak self, weak tab] () -> Void in
                if let icons = self?.mIcons, let tab = tab {
                    icons.forEach({ (t: Tab) in
                        if t != tab {
                            t.state = .inactive
                        }
                    })
                }
                self?.mBlock?()
            }
            mIcons.append(tab)
            addSubview(tab)
        }
        
        mIcons.first?.state = .active

        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0)
    }
    
    func minHeight(`for` w: CGFloat) -> CGFloat {
        return ceil(180.0 + (mIcons.count > 0 ? Dims.icons : 0.0))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        CATransaction.begin()
        CATransaction.setDisableActions(true)
        
        let w: CGFloat = self.width
        let h: CGFloat = self.height
        
        let midH: CGFloat = min(mMid.text?.heightFor(width: w-10, font: mMid.font) ?? 0.0, mMid.font.lineHeight*3.0)
        let topH: CGFloat = min(mTop.text?.heightFor(width: w-10, font: mTop.font) ?? 0.0, mTop.font.lineHeight*2.0)
        
        mBG.frame  = CGRect(x: 0, y: 0, width: w, height: h - 24.0 - (mIcons.count > 0 ? Dims.icons : 0.0))
        mImg.frame = mBG.frame
        mImg.layer.mask?.frame = mImg.bounds
        mSep.frame = CGRect(x: 0, y: mImg.maxY, width: w, height: mSep.height)
        
        mMid.frame   = CGRect(x: 5, y: floor(mBG.maxY-midH-10.0), width: w-10, height: midH)
        mTop.frame   = CGRect(x: 5, y: floor((mBG.maxY - topH)/2.0), width: w-10, height: topH)
        mLogo.origin = CGPoint(x: (w - mLogo.width)/2.0, y: mTop.minY - mLogo.height - 10.0)

        if mIcons.count > 0 {
            var x: CGFloat = floor((w - CGFloat(mIcons.count-1) * Dims.icons)/2.0)
            mIcons.forEach({ (t: Tab) in
                t.center = CGPoint(x: x, y: mImg.maxY + 36.0)
                x += 72.0
            })
        }

        CATransaction.commit()
    }
    
    @objc private func logoTapped() {
        if let id = mHoliday.sponsors.first?.id {
            let hud: HUD? = HUD.show(in: self.window)
            let _ = Service.sponsor(get: id) { (d: Sponsor.Details?, c: Int) in
                hud?.hide(animated: true)
                if let d = d, c == 200, let v = AppDelegate.window {
                    SponsorCardFull(details: d).show(in: v)
                } else {
                    "CANT_GET_SPONSOR".loc.show(in: AppDelegate.window)
                }
            }
        }
    }
    
}
