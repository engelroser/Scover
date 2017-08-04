//
//  CommonVC.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 4/17/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import Alamofire
import UIKit

class CommonVC: UIViewController {
    
    private var mLoader:  HUD?
    private var mGrad:    CAGradientLayer?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isGgradien() {
            mGrad = CAGradientLayer()
            mGrad?.colors     = [UIColor.gradTop.cgColor, UIColor.gradBot.cgColor]
            mGrad?.startPoint = .zero
            mGrad?.endPoint   = CGPoint(x: 1.0, y: 1.0)
            mGrad?.frame      = view.bounds
            view.layer.insertSublayer(mGrad!, at: 0)
        }
        
        self.automaticallyAdjustsScrollViewInsets = false
        self.edgesForExtendedLayout = []
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.interactivePopGestureRecognizer?.delegate = nil
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mGrad?.frame = view.bounds
    }
    
    func isGgradien() -> Bool {
        return true
    }
    
    func back() -> Void {
        navigationController?.popViewController(animated: true)
    }
    
    func close() -> Void {
        if let nc = navigationController {
            nc.dismiss(animated: true)
        } else {
            dismiss(animated: true)
        }
    }
    
    func hud(show: Bool) {
        mLoader?.hide(animated: true)
        mLoader = show ? HUD.show(in: self.view.window) : nil
    }
    
}
