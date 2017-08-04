//
//  SettingsVC.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 27/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Alamofire
import UIKit

class SettingsVC: CommonVC, PushSwitcherDelegate {
    
    private var mRequest: DataRequest?
    
    private lazy var mGallery: Gallery = Gallery(root: self) { [weak self] (img: UIImage) in
        self?.upload(image: img)
    }
    
    private lazy var mPush: PushSwitcher = PushSwitcher(delegate: self, value: AppDelegate.isPushEnabled())
    
    private lazy var mViews: [UIView] = [
        SectionHeader(name: "ACCOUNT_SEC".loc),
        UILabel.label(font: .regular(11.0), text: "UPDATE_PIC".loc, lines: 1, color: .white, alignment: .left, target: self, action: #selector(updateImage)),
        UILabel.label(font: .regular(11.0), text: "RESET_PASS".loc, lines: 1, color: .white, alignment: .left, target: self, action: #selector(resetPass)),
        UILabel.label(font: .regular(11.0), text: "LOGOUT".loc, lines: 1, color: .white, alignment: .left, target: self, action: #selector(logout)),
        SectionHeader(name: "NOTIFICATIONS".loc),
        self.mPush,
        SectionHeader(name: "SUPPORT".loc),
        UILabel.label(font: .regular(11.0), text: "SUP_HELP".loc, lines: 1, color: .white, alignment: .left, target: self, action: #selector(help)),
        UILabel.label(font: .regular(11.0), text: "SUP_REPORT".loc, lines: 1, color: .white, alignment: .left, target: self, action: #selector(report)),
        UILabel.label(font: .regular(11.0), text: "SUP_PRIVACY".loc, lines: 1, color: .white, alignment: .left, target: self, action: #selector(privacy)),
        UILabel.label(font: .regular(11.0), text: "SUP_TERMS".loc, lines: 1, color: .white, alignment: .left, target: self, action: #selector(terms)),
        SectionHeader(name: "SCOVER_SEC".loc),
        UILabel.label(font: .regular(11.0), text: "SCOVER_ABOUT".loc, lines: 1, color: .white, alignment: .left, target: self, action: #selector(about)),
        UILabel.label(font: .regular(11.0), text: "SCOVER_INSPIR".loc, lines: 1, color: .white, alignment: .left, target: self, action: #selector(inspiration)),
    ]
    
    private let mScroll: UIScrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: Icon.cross.view(size: 20, color: .white, target: self, action: #selector(close)))
        self.navigationItem.title = "SETTINGS".loc
        
        NotificationCenter.default.addObserver(self, selector: #selector(pushError), name: .PushEnableError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pushDisabled), name: .PushDisabled, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(pushEnable), name: .PushEnabled, object: nil)
        
        self.view.addSubview(mScroll)
        mViews.forEach { (v: UIView) in
            mScroll.addSubview(v)
        }
    }
    
    @objc private func pushDisabled() {
        mPush.on = false
    }
    
    @objc private func pushEnable() {
        mPush.on = true
    }
    
    @objc private func pushError() {
        "PUSH_ENABLE_ERROR".loc.show(in: self.view.window)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var y: CGFloat = 0.0
        let w: CGFloat = view.width
        
        mViews.forEach { (v: UIView) in
            v.frame = CGRect(x: (v is SectionHeader ? 0.0 : 15.0), y: y, width: w - (v is SectionHeader ? 0.0 : 30.0), height: 47.0)
            y = v.maxY
        }
        mScroll.contentSize = CGSize(width: 0, height: y)
        mScroll.frame = view.bounds
    }
    
    deinit {
        mRequest?.cancel()
        mRequest = nil
    }

    @objc private func help() {
        AppDelegate.open(url: Settings.URL.help)
    }
    
    @objc private func report() {
        AppDelegate.open(url: Settings.URL.report)
    }
    
    @objc private func privacy() {
        AppDelegate.open(url: Settings.URL.privacy)
    }
    
    @objc private func terms() {
        AppDelegate.open(url: Settings.URL.terms)
    }
    
    @objc private func about() {
        AppDelegate.open(url: Settings.URL.about)
    }
    
    @objc private func inspiration() {
        AppDelegate.open(url: Settings.URL.inspiration)
    }
    
    @objc private func updateImage() {
        mGallery.show()
    }
    
    private func upload(image: UIImage) {
        mRequest?.cancel()
        mRequest = nil
        
        let hud: HUD? = HUD.show(in: self.view)
        mRequest = Service.profile(set: image, callback: { [weak self] (r: Bool) in
            hud?.hide(animated: true)
            self?.mRequest = nil
            if r {
                NotificationCenter.default.post(name: .ProfileUpdated, object: nil)
            } else {
                "CANT_UPLOAD_PHOTO".show(in: self?.view.window)
            }
        })
    }
    
    @objc private func resetPass() {
        if let email: String = Settings.profile?.email {
            let hud: HUD? = HUD.show(in: self.view.window)
            let _ = Service.restore(email: email, callback: { [weak self] (_, c: Int) in
                hud?.hide(animated: true)
                (c == 200 ? "MAIL_RESTORED" : "CANT_RESTORE").loc.show(in: self?.view.window)
            })
        } else {
            "EMPTY_EMAIL".loc.show(in: view.window)
        }
    }
    
    @objc private func logout() {
        AppDelegate.logout()
    }
    
    // MARK: - PushSwitcherDelegate methods
    // -------------------------------------------------------------------------
    func push(enabled: Bool) {
        if enabled {
            AppDelegate.enableNotifications()
        } else {
            AppDelegate.disableNotifications()
            Settings.pushTurn = false
        }
    }
    
}
