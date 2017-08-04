//
//  Terms.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 4/21/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class Terms: Popup {

    private let mTitle: UILabel     = UILabel.label(font: .josefinSansBold(20.0), text: "FORGET_PASS_TITLE".loc, lines: 1, color: .white, alignment: .center)
    private let mText:  UITextView  = {
        let tmp: UITextView = UITextView()
        tmp.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 20, right: 0)
        tmp.backgroundColor = .clear
        tmp.contentInset = .zero
        tmp.text = "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum."
        tmp.font = .light(12.0)
        tmp.textColor = .hint
        return tmp
    }()
    private let mSep:   UIImageView = UIImageView(image: .sep())
    private let mBot:   UILabel     = UILabel.label(font: .josefinSansBold(9.0), text: "FORGET_PASS_BOT".loc, lines: 1, color: .white, alignment: .center)
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        root.addSubview(mTitle)
        root.addSubview(mText)
        root.addSubview(mSep)
        root.addSubview(mBot)

        mBot.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(done)))
    }
    
    
    override func forceLayout() {
        super.forceLayout()

        let w: CGFloat = root.width
        let h: CGFloat = root.height
        
        mTitle.origin = CGPoint(x: floor((w - mTitle.width)/2.0), y: 18.0)
        mText.frame   = CGRect(x: 16.0, y: 55.0, width: w - 32.0, height: h - 55.0 - 38.0)
        mBot.frame    = CGRect(x: 0, y: h - 38.0, width: w, height: 38.0)
        mSep.frame    = CGRect(x: 0, y: h - 38.0, width: w, height: mSep.height)
    }
    
    @objc private func done() {
        backCallback?()
    }
    
}
