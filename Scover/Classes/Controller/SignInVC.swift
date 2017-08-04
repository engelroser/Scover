//
//  SignInVC.swift
//  Scover
//
//  Created by Mobile App Dev on 4/17/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import GoogleSignIn

class SignInVC: CommonVC, GIDSignInDelegate, GIDSignInUIDelegate, UIScrollViewDelegate {
    
    private let mFBSDK: FBSDKLoginManager = FBSDKLoginManager()
    
    private let mEnter: UIImageView  = UIImageView(image: .enter())
    private let mLine:  UIImageView  = UIImageView(image: .sep())
    private let mRoot:  UIScrollView = UIScrollView()
    private let mMain:  UIImageView  = UIImageView(image: .main())
    private let mTitle: FadeButton   = FadeButton(name: "SIGN_IN".loc)
    private let mGIcon: LoginWith    = LoginWith(name: "LOGIN_G".loc, icon: .gIcon())
    private let mFIcon: LoginWith    = LoginWith(name: "LOGIN_F".loc, icon: .fIcon())
    private let mProbs: UILabel      = .label(font: .light(13.0), text: "TROUBLE".loc, lines: 1, color: UIColor.white.withAlphaComponent(0.5), alignment: .right) // FONT FIXED

    private lazy var mMail: Field = Field(holder: "HINT_MAIL".loc, icon: .mail(), next: { [weak self] () in
        return self?.mPass.becomeFirstResponder() ?? false
    }, config: { (field: UITextField) in
        field.autocapitalizationType = .none
        field.keyboardType  = .emailAddress
        field.returnKeyType = .next
    })
    
    private lazy var mPass: Field = Field(holder: "HINT_PASS".loc, icon: .pass(), config: { (field: UITextField) in
        field.isSecureTextEntry = true
        field.returnKeyType = .done
    })
    
    private lazy var mKey: String = Keyboard.add(show: { [weak self] (f: CGRect, t: TimeInterval, o: UInt) -> Void in
        guard let s = self else { return }
        if s.mPass.maxY > f.minY {
            UIView.animate(withDuration: t, delay: 0.0, options: UIViewAnimationOptions(rawValue: o), animations: {
                s.mRoot.contentInset.top = f.minY - s.mPass.maxY
            }, completion: nil)
        }
    }, hide: { [weak self] (t: TimeInterval, o: UInt) -> Void in
        guard let s = self else { return }
        UIView.animate(withDuration: t, delay: 0.0, options: UIViewAnimationOptions(rawValue: o), animations: {
            s.mRoot.contentInset.top = 0
        }, completion: nil)
    })
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mRoot)
        
        mRoot.backgroundColor = .mainBG
        mMain.contentMode = .scaleAspectFill
        mRoot.delegate = self
        mRoot.addSubview(mMain)
        mRoot.addSubview(mTitle)
        mRoot.addSubview(mGIcon)
        mRoot.addSubview(mFIcon)
        mRoot.addSubview(mMail)
        mRoot.addSubview(mPass)
        mRoot.addSubview(mEnter)
        mRoot.addSubview(mProbs)
        mRoot.addSubview(mLine)

        mEnter.isUserInteractionEnabled = true
        mEnter.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(enterTapped)))
        mProbs.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(probsTapped)))
        mGIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signInGoogle)))
        mFIcon.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signInFacebook)))
    }
    
    deinit {
        Keyboard.remove(key: mKey)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        let w: CGFloat = view.width

        mRoot.frame   = view.bounds
        mMain.frame   = CGRect(origin: mMain.origin, size: view.bounds.size)
        mTitle.frame  = CGRect(x: 0, y: 214.0 * UIScreen.main.bounds.width/320.0, width: w, height: 48.0)
        
        mFIcon.origin = CGPoint(x: floor((w - mFIcon.width)/2.0), y: ceil(mTitle.minY + 272))
        mGIcon.origin = mFIcon.origin.offset(y: 46.0)

        mMail.frame   = CGRect(x: 0, y: mTitle.maxY, width: w, height: 55.0)
        mPass.frame   = CGRect(x: 0, y: mMail.maxY, width: w, height: 55.0)
        
        mEnter.origin = CGPoint(x: 14.0, y: mPass.maxY + 14.0)
        mLine.frame   = CGRect(x: 0, y: mEnter.maxY + 13.0, width: w, height: mLine.height)
        mProbs.origin = CGPoint(x: w - mProbs.width - 36.0, y: floor(mEnter.center.y - mProbs.height/2.0))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        Keyboard.enable(key: mKey)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        Keyboard.disable(key: mKey);
    }
    
    @objc private func signInGoogle() {
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().signIn()
    }
    
    @objc private func signInFacebook() {
        if let token = FBSDKAccessToken.current()?.tokenString {
            signIn(fbToken: token)
        } else {
            mFBSDK.logIn(withReadPermissions: ["email"], from: self, handler: { [weak self] (r: FBSDKLoginManagerLoginResult?, e: Error?) in
                if let token = r?.token?.tokenString, e == nil {
                    self?.signIn(fbToken: token)
                } else {
                    self?.mFBSDK.logOut()
                }
            })
        }
    }
    
    private func signIn(fbToken token: String) {
        let hud: HUD? = .show(in: view.window)
        let _ = Service.signin(fbToken: token) { [weak self] (a: Auth?, c: Int) in
            hud?.hide(animated: true)
            if let a = a, a.token.characters.count > 0, c == 200 {
                Settings.authToken = a.token
                self?.signIn(success: true)
            } else {
                self?.mFBSDK.logOut()
                self?.signIn(success: false)
            }
        }
    }
    
    private func signIn(gToken token: String) {
        let hud: HUD? = .show(in: view.window)
        let _ = Service.signin(gToken: token) { [weak self] (a: Auth?, c: Int) in
            hud?.hide(animated: true)
            if let a = a, a.token.characters.count > 0, c == 200 {
                Settings.authToken = a.token
                self?.signIn(success: true)
            } else {
                GIDSignIn.sharedInstance().signOut()
                self?.signIn(success: false)
            }
        }
    }
    
    @objc private func enterTapped() {
        let mail: String = mMail.text
        let pass: String = mPass.text
        
        if mail.characters.count == 0 || pass.characters.count == 0 {
            "INCORRECT_PARAMS".loc.show(in: view.window)
            return
        }
        
        let hud: HUD? = .show(in: view.window)
        let _ = Service.signin(email: mail, password: pass) { [weak self] (a: Auth?, c: Int) in
            hud?.hide(animated: true)
            if let a = a, a.token.characters.count > 0, c == 200 {
                Settings.authToken = a.token
                self?.signIn(success: true)
            } else {
                self?.signIn(success: false)
            }
        }
    }
    
    private func signIn(success: Bool) {
        if success {
            AppDelegate.enableNotifications()
            navigationController?.setViewControllers([WelcomeVC()], animated: true)
        } else {
            "ERROR_SIGNIN".loc.show(in: self.view.window)
        }
    }
    
    @objc private func probsTapped() {
        view.endEditing(true)
        Keyboard.disable(key: mKey)
        
        let alert: ForgetPass = ForgetPass(frame: view.bounds)
        alert.show(in: self.view) { 
            self.mRoot.isUserInteractionEnabled = false
            self.mRoot.alpha = 0.0
        }
        alert.backCallback = { [weak self, weak alert] () -> Void in
            alert?.hide { [weak self] () -> Void in
                self?.mRoot.alpha = 1.0
                self?.mRoot.isUserInteractionEnabled = true
            }
            Keyboard.enable(key: self?.mKey)
        }
    }
    
    // MARK: - GIDSignInDelegate, GIDSignInUIDelegate methods
    // -------------------------------------------------------------------------
    func sign(_ tmp: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let user = user, let gToken = user.authentication.accessToken, error == nil {
            signIn(gToken: gToken)
        }
    }
    
    // MARK: - UIScrollViewDelegate methods
    // -------------------------------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 {
            mMain.origin.y = scrollView.contentOffset.y
        } else {
            mMain.origin.y = 0
        }
    }
    
}
