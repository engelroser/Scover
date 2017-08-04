//
//  ProfileHeader.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 23/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

protocol ProfileHeaderDelegate: class {
    func show(photos: PhotosBar.State)
    func showCheckins()
}

class ProfileHeader: UIView {
    
    private let mLine1: UIImageView = UIImageView(image: .sep())
    private let mLine2: UIImageView = UIImageView(image: .sep())
    private let mLine3: UIImageView = UIImageView(image: .sep())
    private let mPhoto: UIImageView = {
        let tmp: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 86, height: 86))
        tmp.backgroundColor = .gray
        tmp.clipsToBounds = true
        tmp.contentMode = .scaleAspectFill;
        tmp.layer.cornerRadius = tmp.width/2.0
        return tmp
    }()

    private let mCheck: UILabel = .label(font: .regular(10.5), text: "", lines: 1, color: .white, alignment: .center)
    private let mName:  UILabel = .label(font: .josefinSansBold(13.0), text: "", lines: 1, color: .white, alignment: .center)
    
    private lazy var mIcons: [UILabel] = [
        Icon.pic.view(size: 16.3, color: .white, target: self, action: #selector(showPhotos)),
        Icon.up.view(size: 16.3, color: .white, target: self, action: #selector(showUp)),
        Icon.check.view(size: 16.3, color: .white, target: self, action: #selector(showCheckins))
    ]
    
    private var mParams: [Param] = [
        Param(name: "PHOTOS".loc),
        Param(name: "CHECKINS".loc)
    ]
    
    private let mTint: UIView = {
        let tmp: UIView = UIView()
        tmp.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        return tmp
    }()
    
    var barHeight: CGFloat {
        return self.height - mLine2.minY
    }

    private lazy var mPhotos: PhotosBar = { [weak self] () -> PhotosBar in
        let tmp: PhotosBar = PhotosBar()
        tmp.callback = { [weak self] (state: PhotosBar.State) -> Void in
            self?.delegate?.show(photos: state)
        }
        return tmp
    }()
    
    private let mBar:  UIView = UIView()
    private let mFade: UIView = {
        let tmp: UIView = UIView()
        tmp.backgroundColor = .gradTop
        tmp.alpha = 0.0
        return tmp
    }()
    var fade: CGFloat {
        get {
            return mFade.alpha
        }
        set {
            mFade.alpha = newValue
        }
    }
    
    weak var delegate: ProfileHeaderDelegate?
    
    private var mProfile: Profile?
    var profile: Profile? {
        get {
            return mProfile
        }
        set {
            mProfile = newValue
            mName.text = "\(mProfile?.firstName ?? "") \(mProfile?.lastName ?? "")"

            switch (mProfile?.checkins ?? 0) {
            case let count where count == 0:
                mCheck.text = "PROF_CHECKIN_NONE".loc
            case let count where count == 1:
                mCheck.text = String(format: "PROF_CHECKIN_ONE".loc, count)
            case let count where count > 1:
                mCheck.text = String(format: "PROF_CHECKIN_MANY".loc, count)
            default: break
            }
            
            mParams[0].count = "\(mProfile?.photos ?? 0)"
            mParams[1].count = "\(mProfile?.checkins ?? 0)"
            
            mPhotos.set(photos: mProfile?.photos ?? 0, likes: mProfile?.likes ?? 0)
            mPhoto.sd_setImage(with: URL(string: mProfile?.avatar?.abs ?? ""))
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(delegate: ProfileHeaderDelegate?) {
        super.init(frame: .zero)
        
        self.delegate = delegate
        
        addSubview(mFade)
        addSubview(mPhoto)
        addSubview(mName)
        addSubview(mLine1)
        addSubview(mLine2)
        addSubview(mLine3)
        addSubview(mTint)
        addSubview(mBar)
        
        mParams.forEach { (p: Param) in
            addSubview(p)
        }
        
        mIcons[1].isHidden = true
        mIcons.forEach { (i: UILabel) in
            addSubview(i)
        }
        
        showPhotos()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w: CGFloat = self.width
        let h: CGFloat = self.height
        
        mFade.frame   = self.bounds
        mPhoto.origin = CGPoint(x: floor((w - mPhoto.width)/2.0), y: 15.0)
        mName.frame   = CGRect(x: 10.0, y: floor(120.0 - mName.font.lineHeight/2.0), width: w - 20.0, height: ceil(mName.font.lineHeight))
        mLine1.frame  = CGRect(x: 0, y: mName.maxY + 10.0, width: w, height: mLine1.height)
        mLine2.frame  = mLine1.frame.offsetBy(dx: 0, dy: 55.0)
        mLine3.frame  = mLine2.frame.offsetBy(dx: 0, dy: 50.0)
        mTint.frame   = CGRect(x: 0, y: mLine1.maxY, width: w, height: mLine2.minY - mLine1.maxY)
        
        let px: CGFloat = mTint.width / CGFloat(mParams.count)
        mParams.enumerated().forEach { (offset: Int, element: Param) in
            element.center = CGPoint(x: CGFloat(offset)*px + px/2.0, y: mTint.center.y)
        }
        
        let ix: CGFloat = w / CGFloat(mIcons.count + 1)
        let ih: CGFloat = mLine3.maxY - mLine2.minY
        mIcons.enumerated().forEach { (offset: Int, element: UILabel) in
            element.frame = CGRect(x: CGFloat(offset+1) * ix - ih/2.0, y: mLine2.minY, width: ih, height: ih)
        }
        
        mBar.frame    = CGRect(x: 0, y: mLine3.minY, width: w, height: h - mLine3.minY)
        mPhotos.frame = mBar.bounds
    }

    func height(`for` width: CGFloat) -> CGFloat {
        return 300.0
    }
    
    @objc private func showPhotos() {
        if select(view: mPhotos, index: 0) {
            delegate?.show(photos: mPhotos.state)
        }
    }
    
    @objc private func showUp() {
        let _ = select(view: nil, index: 1)
    }
    
    @objc private func showCheckins() {
        if select(view: mCheck, index: 2) {
            delegate?.showCheckins()
        }
    }
    
    private func select(view: UIView?, index: Int) -> Bool {
        mIcons.enumerated().forEach { (offset: Int, element: UILabel) in
            element.alpha = offset == index ? 1.0 : 0.5
        }
        
        if view == nil && mBar.subviews.count == 0 { return false }
        
        mBar.subviews.forEach { (v: UIView) in
            if !v.isEqual(view) {
                v.removeFromSuperview()
            }
        }
        
        if let v = view {
            v.frame = mBar.bounds
            v.alpha = 1.0
            if mBar.subviews.count != 0 {
                return false
            } else {
                mBar.addSubview(v)
                return true
            }
        }
        
        return true
    }
    
}
