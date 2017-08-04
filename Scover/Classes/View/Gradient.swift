//
//  Gradient.swift
//  Scover
//
//  Created by Mobile App Dev on 19/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class Gradient: UIView {
    
    private let mGrad: CAGradientLayer = CAGradientLayer()
    
    init(from: (color: UIColor, loc: CGPoint), to: (color: UIColor, loc: CGPoint)) {
        super.init(frame: .zero)
        mGrad.colors     = [from.color.cgColor, to.color.cgColor]
        mGrad.startPoint = from.loc
        mGrad.endPoint   = to.loc
        layer.insertSublayer(mGrad, at: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mGrad.frame = self.bounds
    }
    
}
