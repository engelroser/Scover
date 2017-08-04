//
//  CardContent.swift
//  Scover
//
//  Created by Mobile App Dev on 22/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class CardContent: UIView {
    
    private struct Dims {
        static let gap:      CGFloat = 15.0
        static let smallGap: CGFloat = 10.0
        static let connect:  CGFloat = 66.0
        static let conCap:   CGFloat = 38.0
        static let buttons:  CGFloat = 48.0
        static let links:    CGFloat = 48.0
    }
    
    private lazy var mButtonL: UILabel = .label(font: .josefinSansBold(9.0), text: "SHOW_SOME_LOVE".loc, lines: 1, color: .white, alignment: .center, target: self, action: #selector(like))
    private lazy var mButtonR: UILabel = .label(font: .josefinSansBold(9.0), text: "RETURN".loc, lines: 1, color: .white, alignment: .center, target: self, action: #selector(close))
    
    private let mLine2: UIImageView = UIImageView(image: .sep())
    private let mLine3: UIImageView = UIImageView(image: .sep())
    private let mPhoto: UIImageView = {
        let tmp: UIImageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 86, height: 86))
        tmp.layer.masksToBounds = true
        tmp.layer.cornerRadius  = tmp.width/2.0
        tmp.backgroundColor = .gray
        return tmp
    }()
    
    private let mVideo: UIImageView = {
        let tmp: UIImageView = UIImageView()
        tmp.backgroundColor  = .gray
        tmp.contentMode   = .scaleAspectFill
        tmp.clipsToBounds = true
        return tmp
    }()
    
    private let mWebView: UIWebView = {
        let tmp: UIWebView = UIWebView()
        tmp.backgroundColor = .gray
        return tmp
    }()
    
    private lazy var mLeft:  UILabel = Icon.left.view(size: 12.6, color: .white, padding: 10.0, square: true, target: self, action:#selector(moveLeft))
    private lazy var mRight: UILabel = Icon.right.view(size: 12.6, color: .white, padding: 10.0, square: true, target: self, action:#selector(moveRight))
    
    private let mConnect: UILabel = .label(font: .light(11.0), text: "CONNECT_WITH_US".loc, lines: 1, color: .white, alignment: .center)
    private let mName:    UILabel = .label(font: .josefinSansBold(9.9), text: "TODAYS_SPONSOR".loc, lines: 1, color: .white, alignment: .center)
    private let mTitle:   UILabel = .label(font: .josefinSansBold(13.0), lines: 1, color: .white, alignment: .center)
    private let mDesc:    UILabel = .label(font: .regular(13.0), lines: 0, color: .hint, alignment: .center)
    private let mIcon:    UILabel = Icon.heart.view(size: 13.0, color: .posRed)
    
    private var mLinks: [UILabel] = []
    
    private let mCloseBlock: ()->Void
    
    private var mIndex: Int = 0
    
    private var mDetails: Sponsor.Details
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(details: Sponsor.Details, block: @escaping ()->Void) {
        mCloseBlock = block
        mDetails    = details
        super.init(frame: .zero)
        
        mDesc.text  = mDetails.description
        mTitle.text = mDetails.name
        mPhoto.sd_setImage(with: URL(string: mDetails.logoUrl?.abs ?? ""))
        
        mDetails.links.forEach({ (l: Sponsor.Link) in
            let tmp: UILabel = .label(font: .light(11.0), text: l.name ?? "", lines: 1, color: .lightBlue, alignment: .center, target: self, action: #selector(open(_:)))
            tmp.frame.size = CGSize(width: tmp.width + 10.0, height: Dims.links)
            mLinks.append(tmp)
            addSubview(tmp)
        })

        self.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.layer.cornerRadius  = 2.0
        self.layer.masksToBounds = true
        
        addSubview(mButtonL)
        addSubview(mButtonR)
        if mDetails.media.count > 0 {
            addSubview(mVideo)
            addSubview(mWebView)
        }
        addSubview(mLine2)
        
        if mDetails.media.count > 1 {
            addSubview(mLeft)
            addSubview(mRight)
        }
        
        addSubview(mConnect)
        addSubview(mLine3)
        addSubview(mName)
        addSubview(mPhoto)
        addSubview(mTitle)
        addSubview(mDesc)
        addSubview(mIcon)
        
        mLeft.backgroundColor     = UIColor.black.withAlphaComponent(0.5)
        mLeft.layer.masksToBounds = true
        mLeft.layer.cornerRadius  = mLeft.width/2.0
        
        mRight.backgroundColor     = UIColor.black.withAlphaComponent(0.5)
        mRight.layer.masksToBounds = true
        mRight.layer.cornerRadius  = mRight.width/2.0
        
        refreshMedia()
    }
    
    @objc private func close() {
        mCloseBlock()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        forceLayout()
    }
    
    private func forceLayout() {
        let w: CGFloat  = self.width
        let h: CGFloat  = self.height
        
        mButtonL.frame  = CGRect(x: 0, y: h - Dims.buttons, width: w/2.0, height: Dims.buttons)
        mButtonR.frame  = mButtonL.frame.offsetBy(dx: w/2.0, dy: 0)
        
        if mDetails.media.count > 0 {
            let vw: CGFloat = w / 314.0 * 301.0
            let vh: CGFloat = 176.0 / 301.0 * vw
            
            mVideo.frame   = CGRect(x: (w - vw)/2.0, y: mButtonR.minY - vh, width: vw, height: vh)
            mWebView.frame = mVideo.frame
            mLeft.center   = mVideo.center.offset(x: -vw/2.0 + mLeft.width)
            mRight.center  = mVideo.center.offset(x: vw/2.0 - mLeft.width)
            mLine2.frame   = CGRect(x: 0, y: mVideo.minY - Dims.smallGap - mLine2.height, width: w, height: mLine2.height)
        } else {
            mLine2.frame  = CGRect(x: 0, y: mButtonR.minY - mLine2.height, width: w, height: mLine2.height)
        }

        mLine3.frame   = CGRect(x: 0, y: mLine2.minY - Dims.connect - mLine3.height, width: w, height: mLine3.height)
        mConnect.frame = CGRect(x: 10.0, y: mLine3.maxY, width: w-20.0, height: Dims.conCap)
        
        if mLinks.count > 0 {
            var tmp: CGFloat = 0
            mLinks.forEach { (l: UILabel) in
                if (tmp + l.width) < w {
                    tmp += l.width
                    l.isHidden = false
                } else {
                    l.isHidden = true
                }
            }
            var x: CGFloat = (w - tmp)/2.0
            mLinks.forEach({ (l: UILabel) in
                l.origin = CGPoint(x: x, y: mLine2.minY - Dims.links)
                x = l.maxX;
            })
        }

        mName.origin  = CGPoint(x: floor((w - mName.width)/2.0), y: Dims.gap)
        mPhoto.origin = CGPoint(x: floor((w - mPhoto.width)/2.0), y: mName.maxY + Dims.gap)
        mTitle.frame  = CGRect(x: 10, y: mPhoto.maxY + Dims.gap, width: w-20.0, height: mTitle.font.lineHeight)
        mDesc.frame   = CGRect(x: 10, y: mTitle.maxY + Dims.smallGap, width: w-20.0, height: mLine3.minY - (mTitle.maxY + Dims.smallGap) - Dims.smallGap)
        mIcon.center  = mButtonL.center.offset(x: 60.0)
    }
    
    func height(`for` width: CGFloat) -> CGFloat {
        var h: CGFloat = 0.0
        h += Dims.gap + mName.font.lineHeight
        h += Dims.gap + mPhoto.height
        h += Dims.gap + mTitle.font.lineHeight
        h += Dims.smallGap + (mDesc.text?.heightFor(width: width-20.0, font: mDesc.font) ?? 0.0)
        h += Dims.smallGap + mLine3.height
        h += Dims.connect  + mLine2.height
        h += Dims.buttons
        return ceil((mDetails.media.count > 0 ? (176.0 * width / 314.0 + Dims.smallGap) : 0.0) + h)
    }
    
    @objc private func open(_ sender: UITapGestureRecognizer) {
        if let v = sender.view as? UILabel, let index = mLinks.index(of: v), index < mDetails.links.count {
            AppDelegate.open(url: mDetails.links[index].url?.abs)
        }
    }
    
    @objc private func like() {
        let hud: HUD? = HUD.show(in: self.window)
        let _ = Service.sponsor(like: mDetails.id) { [weak self] (r: Bool) in
            hud?.hide(animated: true)
            if !r {
                "CANT_LIKE_SPONSOR".show(in: self?.window)
            }
        }
    }
    
    @objc private func moveLeft() {
        if mDetails.media.count == 0 { return }
        if mIndex == 0 {
            mIndex = mDetails.media.count
        }
        mIndex -= 1
        refreshMedia()
        
    }
    
    @objc private func moveRight() {
        if mDetails.media.count == 0 { return }
        mIndex += 1
        if mIndex >= mDetails.media.count {
            mIndex = 0
        }
        refreshMedia()
    }
    
    private func refreshMedia() {
        if mIndex >= mDetails.media.count { return }
        let url: String = mDetails.media[mIndex].abs
        print("\(url)")
        if url.hasSuffix("png") || url.hasSuffix("jpeg") || url.hasSuffix("jpg") {
            mWebView.isHidden = true
            mVideo.isHidden   = false
            mVideo.sd_setImage(with: URL(string: url))
            mWebView.stopLoading()
            mWebView.loadHTMLString("", baseURL: nil)
        } else if let urlObj = URL(string: url) {
            mWebView.isHidden = false
            mVideo.isHidden   = true
            mVideo.image      = nil
            mWebView.loadRequest(URLRequest(url: urlObj))
        }
    }
    
}
