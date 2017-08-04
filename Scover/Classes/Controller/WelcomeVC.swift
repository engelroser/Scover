//
//  WelcomeVC.swift
//  Scover
//
//  Created by Mobile App Dev on 4/24/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class WelcomeVC: CommonVC, UIScrollViewDelegate {
    
    private lazy var mScroll: UIScrollView = { [weak self] () -> UIScrollView in
        let tmp: UIScrollView = UIScrollView()
        tmp.clipsToBounds = false
        tmp.showsVerticalScrollIndicator   = false
        tmp.showsHorizontalScrollIndicator = false
        tmp.isPagingEnabled = true
        tmp.delegate = self
        return tmp
    }()
    private let mPages: Paginator     = Paginator(pages: 3)
    private let mViews: [WelcomePage] = [WelcomePage(), WelcomePage(), WelcomePage()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mPages)
        view.addSubview(mScroll)
        mViews.forEach { (p: WelcomePage) in
            mScroll.addSubview(p)
            p.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mScroll.frame = CGRect(x: 30.0, y: 40.0, width: view.width-60.0, height: view.height - 110.0)
        mPages.center = CGPoint(x: view.width/2.0, y: view.height - 44.0)
        
        mScroll.contentSize = CGSize(width: CGFloat(mPages.pages) * mScroll.width, height: 0)
        
        mViews.enumerated().forEach { (i: Int, p: WelcomePage) in
            p.frame = CGRect(x: CGFloat(i)*mScroll.width, y: 0, width: mScroll.width, height: mScroll.height)
        }

        scrollViewDidScroll(mScroll)
    }
    
    @objc private func tapped() {
        navigationController?.setViewControllers([MainVC()], animated: true)
    }
    
    // MARK: - UIScrollViewDelegate methods
    // -------------------------------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let x: CGFloat = scrollView.contentOffset.x
        let w: CGFloat = scrollView.width
        let p: CGFloat = x / w
        
        mPages.active = Int(floor(p))
        if p - floor(p) > 0.5 {
            mPages.active = Int(floor(p)) + 1
        }

        let c1: CGFloat = mScroll.center.x
        mViews.forEach { (p: WelcomePage) in
            p.scale = min(abs(c1 - p.convert(CGPoint(x: p.width/2.0, y: p.height/2.0), to: self.view).x), mScroll.width) / (mScroll.width)
        }
        
    }
    
}
