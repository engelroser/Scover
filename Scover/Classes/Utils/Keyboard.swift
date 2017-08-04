//
//  Keyboard.swift
//  Scover
//
//  Created by Mobile App Dev on 4/20/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

typealias KeyboardWillHide = (TimeInterval, UInt)->Void
typealias KeyboardWillShow = (CGRect, TimeInterval, UInt)->Void

class Keyboard {
    
    private static let mInstance: Keyboard = Keyboard()
    
    static func add(show: @escaping KeyboardWillShow, hide: @escaping KeyboardWillHide) -> String {
        let key: String = UUID().uuidString
        mInstance.mShows[key] = show
        mInstance.mHides[key] = hide
        return key
    }

    static func remove(key: String) {
        disable(key: key)
        mInstance.mShows.removeValue(forKey: key)
        mInstance.mHides.removeValue(forKey: key)
    }
    
    static func enable(key: String?) {
        if let key = key, !mInstance.mEnabled.contains(key) {
            mInstance.mEnabled.append(key)
        }
    }
    
    static func disable(key: String?) {
        if let key = key, let index = mInstance.mEnabled.index(of: key) {
            mInstance.mEnabled.remove(at: index)
        }
    }
    
    private var mShows:   [String: KeyboardWillShow] = [:]
    private var mHides:   [String: KeyboardWillHide] = [:]
    private var mEnabled: [String] = []
    
    private init() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let t = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        guard let o = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt else { return }
        mHides.forEach { (key: String, value: KeyboardWillHide) in
            if mEnabled.contains(key) {
                value(t, o)
            }
        }
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let f = (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        guard let t = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval else { return }
        guard let o = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? UInt else { return }
        mShows.forEach { (key: String, value: KeyboardWillShow) in
            if mEnabled.contains(key) {
                value(f, t, o)
            }
        }
    }
    
}
