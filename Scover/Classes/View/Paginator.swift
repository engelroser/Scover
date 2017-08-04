//
//  Paginator.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 4/24/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class Paginator: UIView {
    
    private let mRoot:  UIView   = UIView()
    private var mViews: [UIView] = []
    
    private var mActive: Int?
    var active: Int? {
        get {
            return mActive
        }
        set {
            if mActive != newValue {
                let count: Int = mViews.count
                if let a = mActive, a < count {
                    set(view: mViews[a], active: false)
                }
                mActive = newValue
                if let a = mActive, count > 0 {
                    mActive = min(count-1, max(0, a))
                    set(view: mViews[mActive!], active: true)
                } else {
                    mActive = nil
                }
            }
        }
    }

    var pages: Int {
        get {
            return mViews.count
        }
        set {
            UIView.performWithoutAnimation {
                mViews.forEach { (v: UIView) in
                    v.removeFromSuperview()
                }
                mViews.removeAll()
                self.active = nil
                mRoot.frame = .zero
                if newValue > 0 {
                    for i in 0..<newValue {
                        let v: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 10.0, height: 10.0))
                        v.layer.cornerRadius = v.width/2.0
                        v.backgroundColor = .white
                        v.center = CGPoint(x: CGFloat(i)*26.0, y: 0)
                        set(view: v, active: false)
                        mViews.append(v)
                        mRoot.addSubview(v)
                    }
                }
                setNeedsLayout()
                layoutIfNeeded()
            }
        }
    }
    
    init(pages: Int) {
        super.init(frame: .zero)
        addSubview(mRoot)
        self.pages = pages
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mViews.enumerated().forEach { (i: Int, v: UIView) in
            v.center = CGPoint(x: CGFloat(i)*26.0, y: 0)
        }
        
        let w: CGFloat = CGFloat(mViews.count-1) * 26.0
        mRoot.frame = CGRect(x: (width - w)/2.0, y: height/2.0, width: w, height: 0)
    }
    
    private func set(view v: UIView, active: Bool) {
        v.transform = active ? .identity : CGAffineTransform(scaleX: 0.8, y: 0.8)
        v.alpha = active ? 0.5 : 0.1
    }
    
}
