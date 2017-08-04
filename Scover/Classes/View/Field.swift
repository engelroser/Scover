//
//  Field.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 4/17/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class Field: UIView, UITextFieldDelegate {
    
    private let mSep:   UIImageView = UIImageView(image: .sep())
    private let mIcon:  UIImageView = UIImageView()
    private let mField: UITextField = {
        let tmp: UITextField = UITextField()
        tmp.textColor = .white
        tmp.tintColor = .white
        tmp.font = .light(13.0) // FONT FIXED
        return tmp
    }()
    
    private let mNext: ((Void)->Bool)?
    
    private var mShift: CGFloat = 20.0
    var shift: CGFloat {
        get {
            return mShift
        }
        set {
            mShift = newValue
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    var text: String {
        return mField.text ?? ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    convenience override init(frame: CGRect) {
        self.init(holder: "", icon: nil)
    }
    
    init(holder: String = "", icon: UIImage? = nil, next: ((Void)->Bool)? = nil, config: ((UITextField)->Void)? = nil) {
        mNext = next
        super.init(frame: .zero)
        addSubview(mIcon)
        addSubview(mField)
        addSubview(mSep)
        
        if let config = config {
            config(mField)
        }
                
        mField.attributedPlaceholder = NSAttributedString(string: holder, attributes: [NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.6),
                                                                                       NSFontAttributeName: UIFont.light(13.0)]) // FONT FIXED
        mField.delegate   = self
        mIcon.contentMode = .center
        mIcon.image = icon
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w: CGFloat = self.width
        let h: CGFloat = self.height
        
        mIcon.frame  = CGRect(x: mShift, y: 0, width: 44.0, height: h)
        mField.frame = CGRect(x: mIcon.maxX, y: 0, width: w - mIcon.maxX - 20.0, height: h)
        mSep.frame   = CGRect(x: 0, y: h - mSep.height, width: w, height: mSep.height)
    }
    
    override func becomeFirstResponder() -> Bool {
        return mField.becomeFirstResponder()
    }
    
    override var isFirstResponder: Bool {
        return mField.isFirstResponder
    }
    
    // MARK: - UITextFieldDelegate methods
    // -------------------------------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if !(mNext?() ?? false) {
            textField.resignFirstResponder()
        }
        return false
    }
    
}
