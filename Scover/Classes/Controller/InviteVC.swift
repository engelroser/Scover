//
//  InviteVC.swift
//  Scover
//
//  Created by Mobile App Dev on 27/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import MessageUI
import FBSDKCoreKit
import FBSDKShareKit

class InviteVC: CommonVC, FBSDKAppInviteDialogDelegate, MFMessageComposeViewControllerDelegate {
    
    private lazy var mViews: [UIView] = [
        SectionHeader(name: "FRIENDS".loc),
        UILabel.label(font: .regular(11.0), text: "CON_FB".loc, lines: 1, color: .white, alignment: .left, target: self, action: #selector(inviteFB)),
        UILabel.label(font: .regular(11.0), text: "CON_CN".loc, lines: 1, color: .white, alignment: .left, target: self, action: #selector(showMock)),
        SectionHeader(name: "SHARE".loc),
        UILabel.label(font: .regular(11.0), text: "SHARE".loc, lines: 1, color: .white, alignment: .left, target: self, action: #selector(doShare))
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: Icon.cross.view(size: 20, color: .white, target: self, action: #selector(close)))
        self.navigationItem.title = "INVITE".loc
        
        mViews.forEach { (v: UIView) in
            self.view.addSubview(v)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        var y: CGFloat = 0.0
        let w: CGFloat = view.width
        
        mViews.forEach { (v: UIView) in
            v.frame = CGRect(x: (v is SectionHeader ? 0.0 : 15.0), y: y, width: w - (v is SectionHeader ? 0.0 : 30.0), height: 47.0)
            y = v.maxY
        }
    }
    
    @objc private func inviteFB() {
        if let url = URL(string: "http://www.scover.today"), let img = URL(string: "http://www.scover.today/assets/images/logo.png") {
            let content: FBSDKAppInviteContent = FBSDKAppInviteContent()
            content.appLinkURL = url
            content.appInvitePreviewImageURL = img
            FBSDKAppInviteDialog.show(from: self, with: content, delegate: self)
        }
    }

    @objc private func showMock() {
        let picker: MFMessageComposeViewController = MFMessageComposeViewController()
        picker.body = "INVITE_MESSAGE".loc
        picker.messageComposeDelegate = self
        present(picker, animated: true)
    }
    
    @objc private func doShare() {
        if let url = URL(string: "http://www.scover.today") {
            present(UIActivityViewController(activityItems: [url], applicationActivities: nil), animated: true)
        }
    }
    
    // MARK: - FBSDKAppInviteDialogDelegate methods
    // -------------------------------------------------------------------------
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didFailWithError error: Error!) {}
    
    func appInviteDialog(_ appInviteDialog: FBSDKAppInviteDialog!, didCompleteWithResults results: [AnyHashable : Any]!) {}
    
    // MARK: - MFMessageComposeViewControllerDelegate methods
    // -------------------------------------------------------------------------
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        dismiss(animated: true)
    }
    
}
