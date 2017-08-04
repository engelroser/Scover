//
//  ForgetPass.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 4/20/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class ForgetPass: Popup {
    
    private let mIcon:  UIImageView = UIImageView(image: .lockRed())
    private let mBot:   UILabel     = UILabel.label(font: .josefinSansBold(9.0), text: "FORGET_PASS_BOT".loc, lines: 1, color: .white, alignment: .center)
    private let mSep2:  UIImageView = UIImageView(image: .sep())
    private let mTitle: UILabel     = UILabel.label(font: .josefinSansBold(20.0), text: "FORGET_PASS_TITLE".loc, lines: 1, color: .white, alignment: .center)
    private let mHint:  UILabel     = UILabel.label(font: .light(12.0), text: "FORGET_PASS_HINT".loc, lines: 0, color: .hint, alignment: .center)
    private let mSep1:  UIImageView = UIImageView(image: .sep())
    
    private lazy var mMail:  Field  = Field(holder: "HINT_MAIL".loc, icon: .mail(), next: { [weak self] () -> Bool in
        self?.done()
        return false
    }, config: { (f: UITextField) in
        f.autocapitalizationType = .none
        f.keyboardType  = .emailAddress
        f.returnKeyType = .done
    })
    
    private lazy var mKey: String = Keyboard.add(show: { [weak self] (f: CGRect, t: TimeInterval, o: UInt) in
        guard let s = self else { return }
        let shift: CGFloat = s.convert(CGPoint(x: 0, y: s.mMail.height), from: s.mMail).y - f.minY
        if shift > 0 {
            UIView.animate(withDuration: t, delay: 0.0, options: UIViewAnimationOptions(rawValue: o), animations: {
                self?.shift = -shift
                self?.forceLayout()
            }, completion: nil)
        }
    }) { [weak self] (t: TimeInterval, o: UInt) in
        UIView.animate(withDuration: t, delay: 0.0, options: UIViewAnimationOptions(rawValue: o), animations: {
            self?.shift = 0
            self?.forceLayout()
        }, completion: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)

        root.addSubview(mIcon)
        root.addSubview(mBot)
        root.addSubview(mSep2)
        root.addSubview(mTitle)
        root.addSubview(mHint)
        root.addSubview(mSep1)
        root.addSubview(mMail)
        
        mMail.shift = 0.0
        mBot.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(backTapped)))
        Keyboard.enable(key: mKey)
    }
    
    deinit {
        Keyboard.remove(key: mKey)
    }
    
    override func forceLayout() {
        super.forceLayout()
        let w: CGFloat = root.width
        let h: CGFloat = root.height
        
        mIcon.origin  = CGPoint(x: floor((w - mIcon.width)/2.0), y: 63.0)
        mBot.frame    = CGRect(x: 0, y: h - 41.0, width: w, height: 41.0)
        mSep2.frame   = CGRect(x: 0, y: h - 41.0 - mSep2.height, width: w, height: mSep2.height)
        mTitle.origin = CGPoint(x: floor((w - mTitle.width)/2.0), y: h/2.0 - 92.0)
        mHint.origin  = CGPoint(x: floor((w - mHint.width)/2.0), y: h/2.0 - 33.0)
        mSep1.frame   = CGRect(x: 0, y: h/2.0 + 50.0, width: w, height: mSep1.height)
        mMail.frame   = CGRect(x: 0, y: mSep1.maxY, width: w, height: 55.0)
    }

    @objc private func backTapped() {
        backCallback?()
    }
    
    @objc private func done() {
        if mMail.text.characters.count == 0 {
            "MAIL_EMPTY".loc.show(in: self.window)
        }
        
        let hud: HUD? = HUD.show(in: self.window)
        let _ = Service.restore(email: mMail.text) { [weak self] (e: Empty?, c: Int) in
            hud?.hide(animated: true)
            if c == 200 {
                self?.backTapped()
                "MAIL_RESTORED".loc.show(in: self?.window)
            } else {
                "CANT_RESTORE".loc.show(in: self?.window)
            }
        }
    }
    
}
