//
//  SponsorCardFull.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 22/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class SponsorCardFull: UIView {
 
    private let mDetails: Sponsor.Details
    private let mBG: CAGradientLayer = {
        let tmp: CAGradientLayer = CAGradientLayer()
        tmp.colors     = [UIColor.gradTop.cgColor, UIColor.gradBot.cgColor]
        tmp.startPoint = .zero
        tmp.endPoint   = CGPoint(x: 1.0, y: 1.0)
        return tmp;
    }()
    
    private lazy var mBlock: CardContent = CardContent(details: self.mDetails) { [weak self] in
        self?.hide()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(details: Sponsor.Details) {
        mDetails = details
        super.init(frame: UIScreen.main.bounds)
        self.layer.insertSublayer(mBG, at: 0)
        self.addSubview(mBlock)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mBG.frame = self.bounds
        
        let w: CGFloat = self.width - 40.0
        let h: CGFloat = min(mBlock.height(for: w), self.height - 40.0)
        
        mBlock.frame = CGRect(x: 20.0, y: floor((self.height - h)/2.0), width: w, height: h)
    }
    
    func show(`in` view: UIView) {
        self.alpha = 0.0
        self.frame = view.bounds
        view.addSubview(self)
        setNeedsLayout()
        layoutIfNeeded()
        UIView.animate(withDuration: 0.25) { 
            self.alpha = 1.0
        }
    }
    
    func hide() {
        UIView.animate(withDuration: 0.25,
                       animations: { 
                        self.alpha = 0.0
        }) { (r: Bool) in
            self.removeFromSuperview()
        }
    }
    
}
