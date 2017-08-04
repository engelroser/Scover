//
//  PullToRefresh.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 03/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class PullToRefresh: UIView {
    
    static let DefaultOffset: CGFloat = 20.0
    
    enum State {
        case pull, refresh
    }
    
    private var mState:  State = .pull
    private let mRadius: CGFloat = 10.0
    private let mParts:  [UIView]
    private var mTimer:  Timer?
    private var mFlush:  Bool = false
    
    var offset: CGFloat = PullToRefresh.DefaultOffset
    
    var state: State {
        return mState
    }
    
    var fire: (()->Void)?
    weak var scroll: UIScrollView?
    
    init(fire: (()->Void)? = nil) {
        var parts: [UIView] = []
        for _ in 1...12 {
            let tmp: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 2.0, height: 7.0))
            tmp.layer.cornerRadius  = 1.0
            tmp.layer.masksToBounds = true
            tmp.backgroundColor     = .white
            parts.append(tmp)
        }
        mParts = parts
        super.init(frame: .zero)
        self.isUserInteractionEnabled = false
        mParts.forEach { (p: UIView) in
            addSubview(p)
        }
        set(progress: 0.0)
        self.fire = fire
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    deinit {
        mTimer?.invalidate()
        mTimer = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let x: CGFloat = self.width/2.0
        let y: CGFloat = self.height/2.0
        let s: CGFloat = 360.0 / CGFloat(mParts.count)
        var a: CGFloat = -90.0
        
        mParts.enumerated().forEach { (offset: Int, element: UIView) in
            element.center = CGPoint(x: x + mRadius * cos(a * CGFloat.pi / 180.0), y: y + mRadius * sin(a * CGFloat.pi / 180.0))
            element.transform = CGAffineTransform(rotationAngle: (a+90) * CGFloat.pi / 180.0)
            a += s
        }
    }

    func start() {
        if self.mState == .pull && !mFlush {
            mFlush = true
            UIView.animate(withDuration: 0.2, animations: {
                self.set(progress: 1.0)
            })
            adjust(top: self.offset*2.0)
        }
    }
    
    func stop() {
        if self.mState == .refresh && mFlush {
            UIView.animate(withDuration: 0.2, animations: { 
                self.set(progress: 0.0)
            }, completion: { (r: Bool) in
                self.mFlush = false
            })
            adjust(top: -self.offset*2.0)
        }
    }
    
    private func adjust(top: CGFloat) {
        let po: CGPoint = self.scroll?.contentOffset ?? .zero
        self.scroll?.contentInset.top += top
        self.scroll?.panGestureRecognizer.isEnabled = false
        let pn: CGPoint = self.scroll?.contentOffset ?? .zero
        self.scroll?.contentOffset = po
        self.scroll?.setContentOffset(pn, animated: true)
        self.scroll?.panGestureRecognizer.isEnabled = true
    }
    
    private func set(progress: CGFloat = 0.0) {
        mTimer?.invalidate()
        mTimer = nil
        
        let p: CGFloat = max(min(1.0, progress), 0.0)
        let s: CGFloat = 1.0 / CGFloat(mParts.count)
        mParts.enumerated().forEach({ (offset: Int, element: UIView) in
            element.alpha = CGFloat(offset+1)*s <= p ? CGFloat(offset+1)*s : 0.0
        })
        
        if p > 0.99 {
            mTimer = Timer.scheduledTimer(withTimeInterval: 1.0/30.0, repeats: true, block: { [weak self] (t: Timer) in
                guard let ss = self else {
                    t.invalidate()
                    return
                }
                ss.mParts.enumerated().forEach({ (offset: Int, element: UIView) in
                    element.alpha -= s
                    if element.alpha < 0.01 || element.alpha == 0.0 {
                        element.alpha = 1.0
                    }
                })
            })
            if let t = mTimer {
                RunLoop.current.add(t, forMode: .commonModes)
                RunLoop.current.add(t, forMode: .defaultRunLoopMode)
            }
            mState = .refresh
        } else {
            mState = .pull
        }
    }
    
    func check(scroll s: UIScrollView) {
        scroll = s
        self.center = CGPoint(x: s.width/2.0, y: s.contentOffset.y + offset)
        let p: CGFloat = -(s.contentOffset.y + s.contentInset.top)/64.0
        
        if mState == .refresh && !s.isTracking && !mFlush {
            mFlush = true
            let p: CGPoint = s.contentOffset
            s.contentInset.top += self.offset*2.0
            s.contentOffset = p
            self.fire?()
        } else if (mState == .pull || p < 1.0) && !mFlush {
            set(progress: p)
        }
        
        if self.superview != s {
            s.addSubview(self)
        } else {
            s.bringSubview(toFront: self)
        }
    }
    
}
