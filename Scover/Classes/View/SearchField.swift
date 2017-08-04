//
//  SearchField.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/11/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

protocol SearchDelegate: class {
    func search(text: String?)
    func search(start: Bool)
}

class SearchField: UIView, UITextFieldDelegate {
    
    enum State {
        case active
        case inactive
    }
    
    private weak var mDelegate: SearchDelegate?
    weak var delegate: SearchDelegate? {
        get {
            return mDelegate
        }
        set {
            mDelegate = newValue
        }
    }
    
    private var mState: State = .inactive
    var state: State {
        get {
            return mState
        }
        set {
            mState = newValue
            UIView.animate(withDuration: 0.2) { 
                self.setNeedsLayout()
                self.layoutIfNeeded()
            }
        }
    }
    
    private var mPrevious: String      = ""
    private let mCancel:   UILabel     = .label(font: .josefinSansRegular(13), text: "CANCEL".loc, lines: 1, color: .white, alignment: .center) // fixed font size
    private let mField:    UITextField = {
        let tmp: UITextField = UITextField()
        tmp.backgroundColor  = .searchBG
        tmp.layer.cornerRadius  = 2.0
        tmp.layer.masksToBounds = true
        tmp.attributedPlaceholder = NSAttributedString(string: "SEARCH_HINT".loc,
                                                       attributes: [NSFontAttributeName: UIFont.regular(13.0),  // fixed font size
                                                                    NSForegroundColorAttributeName: UIColor.white.withAlphaComponent(0.5)])
        tmp.font = .regular(13.0) // fixed font size
        tmp.tintColor = UIColor.white.withAlphaComponent(0.5)
        tmp.textColor = UIColor.white.withAlphaComponent(0.5)
        tmp.leftView  = Icon.search.view(size: 12.0, color: UIColor.white.withAlphaComponent(0.5), padding: 10)
        tmp.leftViewMode  = .always
        tmp.returnKeyType = .search
        return tmp
    }()
    
    var text: String {
        get {
            return mField.text ?? ""
        }
        set {
            mField.text = newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    convenience init(delegate: SearchDelegate? = nil) {
        self.init(frame: .zero)
        self.delegate = delegate
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mCancel)
        addSubview(mField)
        mField.delegate = self;
        mCancel.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(cancelTapped)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w: CGFloat = self.width
        let h: CGFloat = self.height
        
        mField.frame  = CGRect(x: 13.0, y: 10, width: w-26.0 - (mState == .active ? 47.0 : 0.0), height: h-20.0)
        mCancel.frame = CGRect(x: mField.maxX, y: mField.minY, width: w - mField.maxX, height: mField.height)
        mCancel.alpha = mState == .active ? 1.0 : 0.0
    }
    
    @objc private func cancelTapped() {
        if mState == .active {
            self.window?.endEditing(true)
            self.state = .inactive
            self.text  = ""
            if mPrevious != self.text {
                mDelegate?.search(text: nil)
            }
            mDelegate?.search(start: false)
        }
    }
    
    // MARK: - UITextFieldDelegate methods
    // -------------------------------------------------------------------------
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if mPrevious != self.text {
            mDelegate?.search(text: self.text)
            self.state = self.text.characters.count > 0 ? .active : .inactive
        }
        self.window?.endEditing(true)
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.state = .active
        mDelegate?.search(start: true)
    }

}
