//
//  Details.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/9/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import GoogleMaps
import UIKit

class Details: UIView {
    
    private var mObserver: Place.Observer?
    private var mPlace: Place?
    
    private let mLocation: SectionView = {
        let tmp: SectionView = SectionView()
        tmp.name = "LOCATION_INFO".loc
        tmp.icon = Icon.location.view(size: 16.3, color: .white)
        return tmp
    }()
    private let mDirection: SectionView = {
        let tmp: SectionView = SectionView()
        tmp.name = "DIRECTIONS".loc
        tmp.icon = Icon.arrow.view(size: 16.3, color: .white)
        return tmp
    }()
    
    private let mParamsBG: UIView = {
        let tmp: UIView = UIView()
        tmp.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        return tmp
    }()

    private let mAddPhoto: ()->Void
    
    private let mMap: SmallRouteMap = SmallRouteMap()
    private let mSep: UIImageView   = UIImageView(image: .sep())
    
    private let mLikes:    Param = Param(name: "PARAM_LIKES".loc)
    private let mDislikes: Param = Param(name: "PARAM_DISLIKES".loc)
    private let mCheckins: Param = Param(name: "PARAM_CHECKINS".loc)
    private let mBookmark: Param = Param(name: "PARAM_BOOKMARK".loc)
    
    private lazy var mLike: Action = Action(with: .heart, color: .posRed, block: { [weak self] (sender: Action)->Void in
        if let p = self?.mPlace {
            GlobalAction.place(p, like: true)
        }
    })
    private lazy var mDis: Action = Action(with: .negative, block: { [weak self] (sender: Action)->Void in
        if let p = self?.mPlace {
            GlobalAction.place(p, like: false)
        }
    })
    private lazy var mBook: Action = Action(with: .bookmark, block: { [weak self] (sender: Action)->Void in
        if sender.selected {
            GlobalAction.delete(bookmark: self?.mPlace, done: { (r: Bool) in
                if !r {
                    "CANT_DELETE_BOOKMARK".loc.show(in: AppDelegate.window)
                }
            })
        } else {
            GlobalAction.bookmark(place: self?.mPlace)
        }
    })
    private lazy var mCheck: Action = Action(with: .check, bg: false, block: { [weak self] (sender: Action)->Void in
        if let myLoc = Position.shared().coords, let placeLoc = self?.mPlace?.location {
            if myLoc.distance(from: placeLoc) < 200 {
                GlobalAction.check(in: self?.mPlace)
            } else {
                "CHECKIN_TOO_FAR".loc.show(in: self?.window)
            }
        } else {
            "CANT_CHECKIN".loc.show(in: self?.window)
        }
    })
    private lazy var mPhoto: Action = Action(with: .addPhoto, bg: false, block: { [weak self] (sender: Action)->Void in
        self?.mAddPhoto()
    })
    
    private let mTitle:   UILabel = .label(font: .josefinSansBold(25.0), text: "", lines: 1, color: .white, alignment: .center)
    private let mDirText: UILabel = .label(font: .regular(12.0), text: "DIRECTIONS_TO".loc + "\n", lines: 0, color: .white, alignment: .left)
    private let mLocText: UILabel = .label(font: .regular(12.0), text: "", lines: 0, color: .white, alignment: .left)
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = CGRect(x: newValue.minX, y: newValue.minY, width: newValue.width, height: self.maxHeight)
        }
    }
    
    var maxHeight: CGFloat {
        var maxY: CGFloat = 0.0
        subviews.forEach { (v: UIView) in
            maxY = max(v.maxY, maxY)
        }
        return maxY
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(block: @escaping (Route)->Void, photo: @escaping ()->Void) {
        mAddPhoto = photo
        super.init(frame: .zero)
        addSubview(mTitle)
        addSubview(mParamsBG)
        addSubview(mSep)
        addSubview(mLocation)
        addSubview(mDirection)
        addSubview(mLikes)
        addSubview(mDislikes)
        addSubview(mCheckins)
        addSubview(mBookmark)
        addSubview(mLike)
        addSubview(mDis)
        addSubview(mBook)
        addSubview(mCheck)
        addSubview(mPhoto)
        addSubview(mLocText)
        addSubview(mDirText)
        addSubview(mMap)
        
        mCheck.selected = true
        mPhoto.selected = true
        
        mMap.block = block
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
        let w: CGFloat    = self.width
        mTitle.frame      = CGRect(x: 10, y: 0, width: w-20, height: 76.0)
        mParamsBG.frame   = CGRect(x: 0, y: mTitle.maxY, width: w, height: 46)
        mSep.frame        = CGRect(x: 0, y: mParamsBG.maxY, width: w, height: mSep.height)
        mLocation.frame   = CGRect(x: 0, y: 196.0, width: w, height: 48.0)
        mLikes.center     = CGPoint(x: floor((w - 240.0)/2.0), y: mParamsBG.center.y)
        mDislikes.center  = mLikes.center.offset(x: 80.0)
        mCheckins.center  = mDislikes.center.offset(x: 80.0)
        mBookmark.center  = mCheckins.center.offset(x: 80.0)

        mLike.center      = CGPoint(x: floor((w - 248.0)/2.0), y: 160.0)
        mDis.center       = mLike.center.offset(x: 62)
        mBook.center      = mDis.center.offset(x: 62)
        mCheck.center     = mBook.center.offset(x: 62)
        mPhoto.center     = mCheck.center.offset(x: 62)

        mLocText.frame    = CGRect(x: 27.0, y: 242, width: w-54.0, height: ceil((mLocText.text?.heightFor(width: w-54.0, font: mLocText.font) ?? 0) + 20.0))
        mDirection.frame  = CGRect(x: 0, y: mLocText.maxY, width: w, height: 48.0)
        mDirText.frame    = CGRect(x: 27.0, y: mDirection.maxY, width: w-54.0, height: 56.0)
        mMap.frame        = CGRect(x: 0, y: mDirText.maxY, width: w, height: 156.0)
    }
    
    func show(place: Place) {
        mPlace        = place
        mTitle.text   = place.name
        mLocText.text = [place.formatted_address, place.formatted_phone_number, place.hours].flatMap({ $0 }).joined(separator: "\n")
        mDirText.text = "DIRECTIONS_TO".loc + "\n\(place.name)"
        mMap.place    = place
        refresh(place: place)
        forceLayout()
        mObserver?.invalidate()
        mObserver = mPlace?.observe(callback: { [weak self] (updated: Place) in
            self?.refresh(place: updated)
        })
    }
    
    private func refresh(place: Place) {
        mLikes.count    = place.likes <= 0 ? "NO_LIKES".loc : "\(place.likes)"
        mDislikes.count = place.dislikes <= 0 ? "NO_DISLIKES".loc : "\(place.dislikes)"
        mCheckins.count = place.checkins <= 0 ? "NO_CHECKINS".loc : "\(place.checkins)"
        mBookmark.count = place.bookmarks <= 0 ? "NO_BOOKMARKS".loc : "\(place.bookmarks)"
        mLike.selected  = place.like
        mDis.selected   = place.dislike
        mBook.selected  = place.bookmarkId != nil
    }
    
}
