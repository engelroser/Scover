//
//  Welcome.swift
//  Scover
//
//  Created by Mobile App Dev on 4/17/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class StartVC: CommonVC {

    private let mMain:   UIImageView = UIImageView(image: .main())
    private let mSignIn: FadeButton  = FadeButton(name: "SIGN_IN".loc, icon: .go())
    private let mSignUp: FadeButton  = FadeButton(name: "SIGN_UP".loc, icon: .go())

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mMain)
        view.addSubview(mSignIn)
        view.addSubview(mSignUp)
        
        mMain.contentMode = .scaleAspectFill
        mSignIn.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signInTapped)))
        mSignUp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(signUpTapped)))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let w: CGFloat = view.width
        let h: CGFloat = view.height
        
        mMain.frame   = self.view.bounds
        mSignIn.frame = CGRect(x: 0.0, y: h/2.0 - 48.0 - 15.0, width: w, height: 48.0)
        mSignUp.frame = CGRect(x: 0.0, y: h/2.0 + 15.0, width: w, height: 48.0)
    }
    
    @objc private func signInTapped() {
        navigationController?.pushViewController(SignInVC(), animated: true)
    }
    
    @objc private func signUpTapped() {
        navigationController?.pushViewController(SignUpVC(), animated: true)
    }
    
}
