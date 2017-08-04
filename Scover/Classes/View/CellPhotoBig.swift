//
//  PhotoBigCell.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 27/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class CellPhotoBig: UICollectionViewCell {
    
    private let mImage: UIImageView = {
        let tmp: UIImageView = UIImageView(image: UIImage(named: "test2"))
        tmp.backgroundColor = .lightGray
        tmp.layer.cornerRadius  = 4.0
        tmp.layer.masksToBounds = true
        tmp.contentMode = .scaleAspectFill
        return tmp
    }()
    
    private let mFade: UIView = {
        let tmp: UIView = UIView()
        tmp.backgroundColor = UIColor.black.withAlphaComponent(0.4)
        return tmp
    }()
    
    private let mName: UILabel = .label(font: .regular(12.0), text: "", lines: 1, color: .white, alignment: .left)
    private let mDesc: UILabel = .label(font: .regular(10.0), text: "", lines: 1, color: .hint, alignment: .left)
    private let mIcon: UILabel = Icon.heart.view(size: 12.0, color: .white)
    private let mNumb: UILabel = .label(font: .regular(10.0), text: "", lines: 1, color: .white, alignment: .right)
    
    private let mProfile: UIImageView = {
        let tmp: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
        tmp.backgroundColor  = .lightGray
        tmp.layer.cornerRadius  = tmp.width/2.0
        tmp.layer.masksToBounds = true
        return tmp
    }()
    
    private var mPhoto: Profile.Photo?
    var photo: Profile.Photo? {
        get {
            return mPhoto
        }
        set {
            mPhoto = newValue
            mName.text = mPhoto?.location?.name
            mDesc.text = mPhoto?.location?.vicinity
            mNumb.text = "\(mPhoto?.location?.likes ?? 0)"
            mNumb.sizeToFit()
            
            mImage.sd_setImage(with: URL(string: mPhoto?.imgUrl?.abs ?? ""))
            mProfile.sd_setImage(with: URL(string: Settings.profile?.avatar?.abs ?? ""))
            
            forceLayout()
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mImage)
        mImage.addSubview(mProfile)
        mImage.addSubview(mFade)
        mFade.addSubview(mName)
        mFade.addSubview(mDesc)
        mFade.addSubview(mIcon)
        mFade.addSubview(mNumb)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        forceLayout()
    }
    
    private func forceLayout() {
        mProfile.origin = CGPoint(x: 4.0, y: 4.0)
        
        mImage.frame = self.bounds.insetBy(dx: 5.0, dy: 5.0)
        mFade.frame  = CGRect(x: 0, y: mImage.height-45.0, width: mImage.width, height: 45.0)
        
        mNumb.origin = CGPoint(x: mFade.width - 10 - mNumb.width, y: floor((mFade.height - mNumb.height)/2.0))
        mIcon.origin = CGPoint(x: mNumb.minX-4.0 - mIcon.width, y: floor((mFade.height - mIcon.height)/2.0))
        
        mName.frame  = CGRect(x: 6.0, y: floor(mFade.height/2.0 - 8.0 - mName.font.lineHeight/2.0), width: mIcon.minX - 12.0, height: mName.font.lineHeight)
        mDesc.frame  = CGRect(x: 6.0, y: floor(mFade.height/2.0 + 8.0 - mDesc.font.lineHeight/2.0), width: mIcon.minX - 12.0, height: mDesc.font.lineHeight)

    }

}
