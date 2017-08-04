//
//  CommonCell.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 31/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class CommonCell: UITableViewCell {
    
    private struct Dims {
        static let actionSize: CGFloat = 70.0
    }
    
    private var mActions: [Icon] = []
    var actions: [Icon] {
        get {
            return mActions
        }
        set {
            mActions = newValue
            swipeBack()
        }
    }
    
    private var mShift: CGFloat = 0
    var swiped: Bool {
        return mShift < 0.0
    }
    
    private let mView: UIView = UIView()
    var view: UIView {
        return mView
    }
    
    private let mActionsView: UIView = {
        let tmp: UIView = UIView()
        tmp.backgroundColor = .actions
        return tmp
    }()
    
    var actionCallback: ((Icon)->Void)?
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if swiped {
            return mActionsView.point(inside: convert(point, to: mActionsView), with: event)
        }
        return super.point(inside: point, with: event)
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundView   = UIView()
        self.backgroundColor  = .clear
        mView.backgroundColor = .cellFade
        self.selectionStyle   = .none
        
        let left: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedLeft))
        left.direction = .left
        addGestureRecognizer(left)
        
        let right: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(swipedRight))
        right.direction = .right
        addGestureRecognizer(right)
        
        addSubview(mView)
        addSubview(mActionsView)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mView.frame = CGRect(x: mShift, y: 0, width: self.width, height: self.height-15.0)
        mActionsView.frame = CGRect(x: mView.maxX, y: 0, width: CGFloat(mActions.count)*Dims.actionSize, height: mView.height)
        mActionsView.subviews.enumerated().forEach { (offset: Int, element: UIView) in
            element.frame = CGRect(x: CGFloat(offset)*Dims.actionSize, y: 0, width: Dims.actionSize, height: mActionsView.height)
        }
        bringSubview(toFront: mActionsView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    @objc private func actionTapped(_ sender: UITapGestureRecognizer) {
        swipeBack(animated: true)
        if let v = sender.view, let index = mActionsView.subviews.index(of: v), index < mActions.count {
            actionCallback?(mActions[index])
        }
    }
    
    @objc private func swipedLeft() {
        if mShift == 0.0 && mActions.count > 0 {
            mActionsView.subviews.forEach({ (v: UIView) in
                v.removeFromSuperview()
            })
            
            mActions.enumerated().forEach({ (offset: Int, element: Icon) in
                let view: UIView = element.view(size: 16.3, color: .white, target: self, action: #selector(actionTapped(_:)))
                view.frame = CGRect(x: CGFloat(offset)*Dims.actionSize, y: 0, width: Dims.actionSize, height: mActionsView.height)
                mActionsView.addSubview(view)
            })
            
            UIView.animate(withDuration: 0.25, animations: {
                self.mShift = -CGFloat(self.mActions.count) * Dims.actionSize
                self.setNeedsLayout()
                self.layoutIfNeeded()
            })
        }
    }
    
    @objc private func swipedRight() {
        if mShift < 0.0 {
            swipeBack(animated: true)
        }
    }
    
    func swipeBack(animated: Bool = false) {
        guard mShift < 0.0 else { return }
        
        let block: ()->Void = {
            self.mShift = 0.0
            self.setNeedsLayout()
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.25, animations: block)
        } else {
            block()
        }
    }
    
    
    
}
