//
//  MainVC.swift
//  Scover
//
//  Created by Mobile App Dev on 4/25/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class MainVC: CommonVC {
    
    private let mTabVC: UITabBarController = {
        let tmp: UITabBarController = UITabBarController()
        tmp.viewControllers = [
            CustomNC(rootViewController: CalendarVC()),
            CustomNC(rootViewController: MapVC()),
            CustomNC(rootViewController: NewsVC()),
            CustomNC(rootViewController: BookmarksVC()),
            CustomNC(rootViewController: ProfileVC())
        ]
        return tmp
    }()
    
    private let mIcons: [UIView] = [
        Icon.calendar.view(size: 22, color: .white),
        Icon.compas.view(size: 22, color: .white),
        UIImageView(image: .tabIcon3()),
        Icon.bookmark.view(size: 22, color: .white),
        Icon.profile.view(size: 22, color: .white),
    ]
    
    private let mLine: UIImageView = UIImageView(image: .sep())
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addChildViewController(mTabVC)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mTabVC.view)
        view.addSubview(mLine)
        mTabVC.selectedIndex   = 2
        mTabVC.tabBar.isHidden = true
        mTabVC.tabBar.frame    = .zero
        mIcons.forEach { (i: UIView) in
            view.addSubview(i)
            i.contentMode = .center
            i.isUserInteractionEnabled = true
            i.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(selected(icon:))))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mTabVC.navigationController?.setNavigationBarHidden(true, animated: true)
        mTabVC.hidesBottomBarWhenPushed = true
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        let w: CGFloat = view.width
        let h: CGFloat = view.height
        
        mTabVC.view.frame   = CGRect(x: 0, y: 0, width: w, height: h - 62.0)
        mTabVC.tabBar.frame = CGRect(x: 0, y: mTabVC.view.maxY, width: mTabVC.view.width, height: 0)
        mLine.frame         = CGRect(x: 0, y: mTabVC.view.maxY, width: w, height: mLine.height)
        
        let s: CGFloat = view.width/CGFloat(mIcons.count)
        mIcons.enumerated().forEach { (offset: Int, element: UIView) in
            element.frame = CGRect(x: floor(CGFloat(offset) * s), y: mLine.minY, width: ceil(s), height: h - mLine.minY)
        }
    }
    
    @objc private func selected(icon sender: UITapGestureRecognizer) {
        if let v = sender.view, let index: Int = mIcons.index(of: v) {
            mTabVC.selectedIndex = index
        }
    }
    
}
