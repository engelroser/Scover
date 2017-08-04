//
//  PushSwitcher.swift
//  Scover
//
//  Created by Mobile App Dev on 28/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

protocol PushSwitcherDelegate: class {
    func push(enabled: Bool)
}

class PushSwitcher: UIView {
    
    private let mSwitch: UISwitch = UISwitch()
    private let mName: UILabel = .label(font: .regular(11.0), text: "PUSH_NOTIF".loc, lines: 1, color: .white, alignment: .left)
    private weak var mDelegate: PushSwitcherDelegate?
    
    var on: Bool {
        get {
            return mSwitch.isOn
        }
        set {
            mSwitch.setOn(newValue, animated: true)
        }
    }

    init(delegate: PushSwitcherDelegate?, value: Bool) {
        super.init(frame: .zero)
        mDelegate = delegate
        mSwitch.isOn = value
        mSwitch.isUserInteractionEnabled = false
        addSubview(mName)
        addSubview(mSwitch)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggled)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mName.frame = self.bounds
        mSwitch.origin = CGPoint(x: floor(width - mSwitch.width), y: floor((height - mSwitch.height)/2.0))
    }
    
    @objc private func toggled() {
        mDelegate?.push(enabled: !mSwitch.isOn)
    }
    
}
