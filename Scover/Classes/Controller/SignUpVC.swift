//
//  SignUp.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 4/19/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import MBProgressHUD

class SignUpVC: CommonVC, UIScrollViewDelegate {

    private var mHide:  Bool = true
    private var mFocus: Field? {
        return [mName, mMail, mPass, mConf].filter { $0.isFirstResponder }.first
    }
    private let mHint:  UILabel      = UILabel.label(font: .light(11.0), text: "AGREE".loc, lines: 1, color: UIColor.white.withAlphaComponent(0.5), alignment: .center)
    private let mRoot:  UIScrollView = UIScrollView()
    private let mMain:  UIImageView  = UIImageView(image: .main())
    private lazy var mSave: UIImageView = { [weak self] () -> UIImageView in
        let tmp: UIImageView = UIImageView(image: .ok())
        tmp.isUserInteractionEnabled = true
        tmp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(okTapped)))
        return tmp
    }()
    private let mTitle: FadeButton   = FadeButton(name: "SIGN_UP".loc)

    private lazy var mName: Field = Field(holder: "HINT_NAME".loc, icon: .user(), next: { [weak self] () in
        return self?.mMail.becomeFirstResponder() ?? false
    }, config: { (field: UITextField) in
        field.autocapitalizationType = .words
        field.keyboardType  = .default
        field.returnKeyType = .next
    })
    
    private lazy var mMail: Field = Field(holder: "HINT_MAIL".loc, icon: .mail(), next: { [weak self] () in
        return self?.mPass.becomeFirstResponder() ?? false
    }, config: { (field: UITextField) in
        field.autocapitalizationType = .none
        field.keyboardType  = .emailAddress
        field.returnKeyType = .next
    })

    private lazy var mPass: Field = Field(holder: "HINT_PASS".loc, icon: .pass(), next: { [weak self] () in
        return self?.mConf.becomeFirstResponder() ?? false
    }, config: { (field: UITextField) in
        field.isSecureTextEntry = true
        field.returnKeyType = .next
    })
    
    private lazy var mConf: Field = Field(holder: "HINT_CONF".loc, icon: .pass(), config: { (field: UITextField) in
        field.isSecureTextEntry = true
        field.returnKeyType = .done
    })
    
    private lazy var mKey: String = Keyboard.add(show: { [weak self] (f: CGRect, t: TimeInterval, o: UInt) in
        guard let s = self else { return }
        s.mHide = false
        UIView.animate(withDuration: t, delay: 0.0, options: UIViewAnimationOptions(rawValue: o), animations: {
            s.mRoot.contentInset.bottom = max(s.mConf.maxY - f.minY, 0)
            if s.mRoot.contentInset.bottom > 0 && s.mFocus?.isFirstResponder ?? false {
                s.mRoot.contentOffset.y = max((s.mFocus?.maxY ?? 0) - f.minY, 0)
            }
        }, completion: { (r: Bool) in
            s.mHide = true
        })
    }) { [weak self] (t: TimeInterval, o: UInt) in
        guard let s = self else { return }
        UIView.animate(withDuration: t, delay: 0.0, options: UIViewAnimationOptions(rawValue: o), animations: {
            s.mRoot.contentInset.bottom = 0
        }, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mRoot)
        
        mRoot.backgroundColor = .mainBG
        mRoot.delegate = self
        
        mMain.contentMode = .scaleAspectFill

        mRoot.addSubview(mMain)
        mRoot.addSubview(mTitle)
        mRoot.addSubview(mName)
        mRoot.addSubview(mMail)
        mRoot.addSubview(mPass)
        mRoot.addSubview(mConf)
        mRoot.addSubview(mSave)
        mRoot.addSubview(mHint)
        
        Keyboard.enable(key: mKey)
        
        mHint.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showTerms)))
    }
    
    deinit {
        Keyboard.remove(key: mKey)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let w: CGFloat = view.width
        mRoot.frame    = view.bounds
        mMain.frame    = view.bounds
        mTitle.frame   = CGRect(x: 0, y: 214.0 * UIScreen.main.bounds.width/320.0, width: w, height: 48.0)
        mName.frame    = CGRect(x: 0, y: mTitle.maxY, width: w, height: 55.0)
        mMail.frame    = CGRect(x: 0, y: mName.maxY, width: w, height: 55.0)
        mPass.frame    = CGRect(x: 0, y: mMail.maxY, width: w, height: 55.0)
        mConf.frame    = CGRect(x: 0, y: mPass.maxY, width: w, height: 55.0)
        mSave.origin   = CGPoint(x: floor((w - mSave.width)/2.0), y: mConf.maxY + 22.0)
        mHint.origin   = CGPoint(x: floor((w - mHint.width)/2.0), y: max(mSave.maxY + 40, view.height - 25))
        
        mRoot.contentSize.height = max(mHint.maxY + 10, view.maxY)
    }
    
    @objc private func okTapped() {
        self.view.window?.endEditing(true)
        
        let p: [String] = mName.text.components(separatedBy: " ")
        if p.count < 2 {
            "INCORRECT_NAMES".loc.show(in: view.window)
            return
        }
        
        let fpass: String = mPass.text
        let spass: String = mConf.text
        if (fpass != spass || fpass.characters.count == 0) {
            "INCORRECT_PASS".loc.show(in: view.window)
            return
        }
        
        let email: String = mMail.text
        if email.characters.count == 0 {
            "INCORRECT_MAIL".loc.show(in: view.window)
        }
        
        let hud: HUD? = .show(in: view.window)
        let _ = Service.signup(email: email, password: fpass, first: p[0], last: p[1..<p.count].joined(separator: " ")) { [weak self] (a: Auth?, c: Int) in
            hud?.hide(animated: true)
            if let a = a, a.token.characters.count > 0 {
                Settings.authToken = a.token
                self?.navigationController?.setViewControllers([MainVC()], animated: true)
            } else {
                "ERROR_SIGNUP".loc.show(in: self?.view.window)
            }
        }
    }
    
    @objc private func showTerms() {
        view.endEditing(true)
        Keyboard.disable(key: mKey)
        
        let terms: Terms = Terms(frame: view.bounds)
        terms.show(in: view) { 
            self.mRoot.alpha = 0.0
        }
        terms.backCallback = { [weak self, weak terms] () -> Void in
            terms?.hide { [weak self] () -> Void in
                self?.mRoot.alpha = 1.0
                self?.mRoot.isUserInteractionEnabled = true
            }
            Keyboard.enable(key: self?.mKey)
        }
    }

    // MARK: - UIScrollViewDelegate methods
    // -------------------------------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if mHide {
            view.endEditing(true)
        }
        if scrollView.contentOffset.y < 0 {
            mMain.origin.y = scrollView.contentOffset.y
        } else {
            mMain.origin.y = 0
        }
    }
    
}
