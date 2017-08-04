//
//  NewsTile.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 4/25/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class NewsTile: UIView {
    
    private let mImage: UIImageView = {
        let tmp: UIImageView = UIImageView()
        tmp.alpha = 0.4
        tmp.contentMode = .scaleAspectFill
        tmp.clipsToBounds = true
        return tmp
    }()
    
    private let mTitle:  UILabel = .label(font: .josefinSansBold(20.0), text: "", lines: 1, color: .white, alignment: .center)
    private let mDesc:   UILabel = .label(font: .regular(14.0), text: "", lines: 0, color: UIColor.white.withAlphaComponent(0.75), alignment: .center)
    private let mCenter: UILabel = .label(font: .regular(12.0), text: "", lines: 1, color: .white, alignment: .center)
    private let mError:  UILabel = .label(font: .regular(14.0), text: "CANT_LOAD_HOLIDAYS".loc, lines: 1, color: .white, alignment: .center)
    
    private lazy var mLogoR: UIImageView = { [weak self] in
        let tmp: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        tmp.clipsToBounds = true
        tmp.layer.cornerRadius = tmp.width/2.0
        tmp.contentMode = .scaleAspectFill
        tmp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openSponsor)))
        tmp.isUserInteractionEnabled = true
        return tmp
    }()
    
    private lazy var mLogoL: UIImageView = { [weak self] in
        let tmp: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        tmp.contentMode = .scaleAspectFill
        tmp.clipsToBounds = true
        tmp.layer.cornerRadius = tmp.width/2.0
        tmp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(openSponsor)))
        tmp.isUserInteractionEnabled = true
        return tmp
    }()
    
    private let mHUD: UIActivityIndicatorView = .white
    
    private let mBlock:  (UInt64)->Void
    private let mTapped: ()->Void
    
    private var mCount: UInt64?
    var count: UInt64? {
        get {
            return mCount
        }
        set {
            mError.isHidden = true
            mCount = newValue
            if let c = mCount {
                mCenter.isHidden = false
                mCenter.text = c == 0 ? "NO_HOLIDAYS".loc : ("\(c) " + (c == 1 ? "HOLIDAY" : "HOLIDAYS").loc)
                mCenter.sizeToFit()
                setNeedsLayout()
                layoutIfNeeded()
                mHUD.stopAnimating()
            } else {
                mCenter.isHidden = true
                mHUD.startAnimating()
            }
        }
    }
    
    var error: Bool {
        get {
            return !mError.isHidden
        }
        set {
            mError.isHidden = !newValue
            if newValue {
                mHUD.stopAnimating()
            } else {
                self.count = mCount
            }
        }
    }
    
    private var mUI: Holiday.UI?
    var ui: Holiday.UI? {
        get {
            return mUI
        }
        set {
            mUI = newValue
            mDesc.text = mUI?.description
            mTitle.text = mUI?.title ?? mTitleBackup
            mImage.sd_setImage(with: URL(string: mUI?.backgroundUrl?.abs ?? ""), placeholderImage: mPlaceholder)
            forceLayout()
            
            if let url = mUI?.sponsors.first?.logoUrl?.abs {
                mLogoL.isHidden = false
                mLogoR.isHidden = false
                
                mLogoL.sd_setImage(with: URL(string: url))
                mLogoR.sd_setImage(with: URL(string: url))
            } else {
                mLogoL.isHidden = true
                mLogoR.isHidden = true
            }
        }
    }
    
    private let mTitleBackup: String
    private let mPlaceholder: UIImage
    
    private lazy var mTapArea: UIView = { [weak self] () -> UIView in
        let tmp: UIView = UIView()
        tmp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        return tmp
    }()
    
    init(image: UIImage, name: String, callback: @escaping (UInt64)->Void, tapped: @escaping ()->Void) {
        mPlaceholder = image
        mTitleBackup = name
        mTapped = tapped
        mBlock = callback
        
        super.init(frame: .zero)
        mImage.image = image
        addSubview(mImage)
        
        mTitle.text = name
        mTitle.sizeToFit()
        addSubview(mTitle)
        addSubview(mDesc)
        
        mCenter.layer.borderWidth = 1
        mCenter.layer.borderColor = UIColor.white.cgColor
        addSubview(mCenter)
        addSubview(mError)
        addSubview(mHUD)
        
        addSubview(mTapArea)
        
        addSubview(mLogoL)
        addSubview(mLogoR)
        
        self.count = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        forceLayout()
    }
    
    private func forceLayout() {
        let w: CGFloat = self.width
        let h: CGFloat = self.height
        
        mImage.frame  = self.bounds
        mTitle.origin = CGPoint(x: floor((w - mTitle.width)/2.0), y: floor(h/2.0 - 38.0 - mTitle.height))
        mDesc.frame   = CGRect(x: 20, y: h/2.0 + 38.0, width: w - 40.0, height: ceil(mDesc.text?.heightFor(width: w-40.0, font: mDesc.font) ?? 0))
        
        var tmp: CGSize = mCenter.sizeThatFits(CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude))
        tmp.width  += 28.0
        tmp.height += 28.0
        mCenter.frame = CGRect(x: floor((w - tmp.width)/2.0), y: floor((h - tmp.height)/2.0), width: ceil(tmp.width), height: ceil(tmp.height))
        mHUD.center   = mCenter.center
        mError.center = mCenter.center
        
        mTapArea.frame = self.bounds
        mLogoL.center  = CGPoint(x: 41.0, y: h/2.0)
        mLogoR.center  = CGPoint(x: w-41.0, y: h/2.0)
    }
    
    @objc private func openSponsor() {
        if let id = mUI?.sponsors.first?.id {
            mBlock(id)
        }
    }
    
    @objc private func tapped() {
        mTapped()
    }
    
}
