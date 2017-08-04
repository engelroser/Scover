//
//  Tab.swift
//  Scover
//
//  Created by Mobile App Dev on 5/5/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import SDWebImage

class Tab: UIView {
    
    enum State {
        case active
        case inactive
    }
    
    private let mImg: UIImageView = UIImageView(image: .tabBG())
    private let mBot: UILabel = .label(font: .regular(10), text: "", lines: 1, color: .white, alignment: .center) // fixed font
    
    private let mActive:   URL?
    private let mInactive: URL?

    private var mState: State = .inactive
    var state: State {
        get {
            return mState
        }
        set {
            mState = newValue
            mBot.alpha = (mState == .inactive) ? 0.5 : 1.0
            mImg.sd_setImage(with: mState == .inactive ? mInactive : mActive)
        }
    }

    var block: (()->Void)?
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(title: String?, active: String?, inactive: String?) {
        mActive   = URL(string: active ?? "")
        mInactive = URL(string: inactive ?? "")
        super.init(frame: .zero)
        addSubview(mImg)
        addSubview(mBot)
        
        var urls: [URL] = []
        if let url = mActive {
            urls.append(url)
        }
        if let url = mInactive {
            urls.append(url)
        }
        SDWebImagePrefetcher.shared().prefetchURLs(urls)
        
        self.state    = .inactive
        mBot.text     = title
        mBot.isHidden = title == nil
        mBot.sizeToFit()
        mBot.frame.size.width  = ceil(mBot.width)
        mBot.frame.size.height = ceil(mBot.height)
        
        mImg.contentMode        = .scaleAspectFill
        mImg.clipsToBounds      = true
        mImg.layer.cornerRadius = mImg.width/2.0
        mImg.layer.borderWidth  = 1.0
        mImg.layer.borderColor  = UIColor.white.cgColor
        mImg.backgroundColor    = .gradBot
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mImg.center = self.bounds.center()
        mBot.center = mImg.center.offset(y: 32.0)
    }
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return (mImg.point(inside: mImg.convert(point, from: self), with: event) || mBot.point(inside: mBot.convert(point, from: self), with: event))
    }
    
    @objc private func tapped() {
        if mState == .inactive {
            self.state = .active
            block?()
        }
    }
    
}
