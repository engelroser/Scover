//
//  PhotosBar.swift
//  Scover
//
//  Created by Mobile App Dev on 27/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class PhotosBar: UIView {
    
    enum State: Int {
        case single   = 0
        case multiple = 1
    }
    
    var state: State {
        get {
            return mSingle.alpha > 0.75 ? .single : .multiple
        }
        set {
            mSingle.alpha = newValue == .single ? 1.0 : 0.5
            mMultiple.alpha = newValue == .multiple ? 1.0 : 0.5
        }
    }
    
    private lazy var mLabel:    UILabel = .label(font: .regular(11.0), text: "", lines: 1, color: .white, alignment: .left)
    private lazy var mMultiple: UILabel = Icon.multiple.view(size: 16.3, color: .white, target: self, action: #selector(showMultiple))
    private lazy var mSingle:   UILabel = Icon.single.view(size: 16.3, color: .white, target: self, action: #selector(showSingle))
    
    var callback: ((State)->Void)?
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mLabel)
        addSubview(mSingle)
        addSubview(mMultiple)
        
        self.state = .multiple
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w: CGFloat = self.width
        let h: CGFloat = self.height
        
        mLabel.frame    = CGRect(x: 22.0, y: 0, width: w - 44.0, height: h)
        mMultiple.frame = CGRect(x: w - 54 - h/2.0, y: 0, width: h, height: h)
        mSingle.frame   = mMultiple.frame.offsetBy(dx: -h, dy: 0)
    }
    
    @objc private func showSingle() {
        if self.state != .single {
            self.state = .single
            callback?(self.state)
        }
    }
    
    @objc private func showMultiple() {
        if self.state != .multiple {
            self.state = .multiple
            callback?(self.state)
        }
    }
    
    func set(photos: UInt64, likes: UInt64) {
        var values: [String] = []
        switch photos {
        case let c where c == 1:
            values.append(String(format: "PROF_PHOTO".loc, c))
        case let c where c > 1 :
            values.append(String(format: "PROF_PHOTOS".loc, c))
        default:
            values.append("PROF_NO_PHOTOS".loc)
        }
        
        switch likes {
        case let c where c == 1:
            values.append(String(format: "PROF_LIKE".loc, c))
        case let c where c > 1 :
            values.append(String(format: "PROF_LIKES".loc, c))
        default:
            values.append("PROF_NO_LIKES".loc)
        }
        
        mLabel.text = values.joined(separator: " ")
    }
    
}
