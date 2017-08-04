//
//  TransView.swift
//  Scover
//
//  Created by Mobile App Dev on 5/11/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class TransView: UIView {
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return subviews.filter({ (v: UIView) -> Bool in
            return v.point(inside: self.convert(point, to: v), with: event)
        }).count > 0
    }
    
}
