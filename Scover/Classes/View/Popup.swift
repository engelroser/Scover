//
//  Popup.swift
//  Scover
//
//  Created by Mobile App Dev on 4/21/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class Popup: UIView {
    private let mBlack: UIView = {
        let tmp: UIView = UIView()
        tmp.backgroundColor = .fade
        tmp.layer.cornerRadius = 6.0
        return tmp
    }()

    var backCallback: (()->Void)?
    var shift: CGFloat = 0.0
    var root:  UIView {
        return mBlack
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mBlack)
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(endEditing(_:))))
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        forceLayout()
    }
    
    func forceLayout() {
        mBlack.frame = CGRect(x: 30.0, y: 55.0 + self.shift, width: width - 60.0, height: height - 110.0)
    }
    
    func show(`in` view: UIView, block: @escaping ()->Void) {
        view.addSubview(self)
        self.alpha = 0.0
        forceLayout()
        UIView.animate(withDuration: 0.25) {
            self.alpha = 1.0
            block()
        }
    }
    
    func hide(block: @escaping ()->Void) {
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 0.0
            block()
        }, completion: { (r: Bool) in
            self.removeFromSuperview()
        })
    }
    
}
