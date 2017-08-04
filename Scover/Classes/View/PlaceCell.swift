//
//  PlaceCell.swift
//  Scover
//
//  Created by Mobile App Dev on 5/3/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class PlaceCell: CommonCell {
    
    var likedBlock:    ((Place)->Void)?
    var dislikedBlock: ((Place)->Void)?
    
    private let mBot: UIImageView = UIImageView(image: .sep())
    private let mTop: UIImageView = UIImageView(image: .sep())
    
    private let mName: UILabel   = .label(font: .josefinSansRegular(15), text: "", lines: 1, color: .white, alignment: .left) // fixed font
    private let mDesc: UILabel   = .label(font: .light(14.0), text: "", lines: 1, color: UIColor.white.withAlphaComponent(0.5), alignment: .left) // fixed font
    private let mDist: UILabel   = .label(font: .light(14.0), text: "", lines: 1, color: UIColor.white.withAlphaComponent(0.5), alignment: .left) // fixed font
    private let mPos:  UILabel   = UILabel()
    private let mNeg:  UILabel   = UILabel()
    private let mIcon: PlaceIcon = PlaceIcon()
    
    private var mObserver: Place.Observer?
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.view.backgroundColor = .darkBlue
        self.view.addSubview(mName)
        self.view.addSubview(mDesc)
        self.view.addSubview(mDist)
        self.view.addSubview(mBot)
        self.view.addSubview(mTop)
        self.view.addSubview(mIcon)
        self.view.addSubview(mPos)
        self.view.addSubview(mNeg)
        
        mPos.isUserInteractionEnabled = true
        mPos.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(liked)))
        
        mNeg.isUserInteractionEnabled = true
        mNeg.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(disliked)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    deinit {
        mObserver?.invalidate()
        mObserver = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        forceLayout()
    }
    
    private func forceLayout() {
        let w: CGFloat = self.view.width
        let h: CGFloat = self.view.height
        let p: CGFloat = mIcon.isHidden ? 0 : 50.0
        
        mPos.sizeToFit()
        mNeg.sizeToFit()
        
        mTop.frame   = CGRect(x: 0, y: 0, width: w, height: mTop.height)
        mBot.frame   = CGRect(x: 0, y: h-mBot.height, width: w, height: mBot.height)
        mIcon.center = CGPoint(x: 30.0, y: h/2.0)
        mPos.frame   = CGRect(x: w - 16 - ceil(mPos.width), y: floor(h/2.0 - 12.0 - mPos.height/2.0), width: ceil(mPos.width), height: ceil(mPos.height))
        mNeg.frame   = CGRect(x: w - 16 - ceil(mNeg.width), y: floor(h/2.0 + 12.0 - mNeg.height/2.0), width: ceil(mNeg.width), height: ceil(mNeg.height))
        mName.frame  = CGRect(x: 10.0 + p, y: 9, width: min(mPos.minX, mNeg.minX) - (20.0 + p), height: 14.0)
        mDesc.frame  = CGRect(x: 10.0 + p, y: floor((h - mDesc.font.lineHeight)/2.0), width: min(mPos.minX, mNeg.minX) - (20.0 + p), height: mDesc.font.lineHeight)
        mDist.frame  = CGRect(x: 10.0 + p, y: mDesc.maxY, width: min(mPos.minX, mNeg.minX) - (20.0 + p), height: mDist.font.lineHeight)
    }
    
    func attach(place: Place, icon: String?) {
        mName.text = place.name
        mDesc.text = place.vicinity
        mDist.text = place.geometry?.distance(to: Position.shared().coords) ?? ""
        mIcon.attach(place: place, icon: icon)
        update(place: place)

        mObserver?.invalidate()
        mObserver = place.observe(callback: { [weak self] (p: Place) in
            self?.update(place: p)
        })
    }
    
    private func update(place: Place) {
        mPos.attributedText = place.likes.likes()
        mNeg.attributedText = place.dislikes.dislikes()
        mPos.alpha = place.like ? 1.0 : 0.7
        mNeg.alpha = place.dislike ? 1.0 : 0.7
        forceLayout()
    }

    @objc private func liked() {
        if let p = mObserver?.place, !p.like {
            likedBlock?(p)
        }
    }
    
    @objc private func disliked() {
        if let p = mObserver?.place, !p.dislike {
            dislikedBlock?(p)
        }
    }
    
}
