//
//  Footer.swift
//  Scover
//
//  Created by Mobile App Dev on 21/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class Footer: UIView {
    
    private struct Dims {
        static let height: CGFloat = 100.0
    }
    
    enum State {
        case loading
        case error
        case hidden
    }
    
    private weak var mScroll: UIScrollView?
    private var mState: State = .hidden
    var state: State {
        get {
            return mState
        }
        set {
            mState = newValue
            switch mState {
            case .loading:
                mScroll?.contentInset.bottom = Dims.height
                mError.isHidden = true
                mLoader.startAnimating()
            case .error:
                mScroll?.contentInset.bottom = Dims.height
                mError.isHidden = false
                mLoader.stopAnimating()
            case .hidden:
                mScroll?.contentInset.bottom = 0
                mError.isHidden = true
                mLoader.stopAnimating()
            }
            adjust()
        }
    }
    
    private let mBlock:  (()->Void)?
    private let mError:  UILabel = .label(font: .regular(14.0), text: "PHOTO_LOAD_ERROR".loc, lines: 1, color: .white, alignment: .center)
    private let mLoader: UIActivityIndicatorView = .white
    
    init(scroll: UIScrollView, state: State = .hidden, error: (()->Void)?) {
        mBlock = error
        super.init(frame: CGRect(x: 0.0, y: scroll.contentSize.height, width: scroll.width, height: Dims.height))
        mScroll = scroll
        self.state = state
        mError.isUserInteractionEnabled = true
        mError.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(doRepeat)))
        mScroll?.addSubview(self)
        
        addSubview(mLoader)
        addSubview(mError)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    @objc private func doRepeat() {
        mBlock?()
    }
    
    func adjust() {
        if let s = mScroll {
            self.origin = CGPoint(x: (s.width - self.width)/2.0, y: s.contentSize.height)
            mError.center  = self.bounds.center()
            mLoader.center = mError.center
        }
    }
    
}
