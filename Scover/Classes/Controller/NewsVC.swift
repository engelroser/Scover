//
//  NewsVC.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 4/25/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class NewsVC: CommonVC {
    
    private lazy var mBlock: (UInt64)->Void = { [weak self] (id: UInt64)->Void in
        self?.open(sponsor: id)
    }
    
    private lazy var mTiles: [NewsTile] = [
        NewsTile(image: .todayBG(), name: "NEWS_TODAY_NAME".loc, callback: self.mBlock, tapped: { [weak self] in
            self?.navigationController?.pushViewController(TodayVC(), animated: true)
        }),
        NewsTile(image: .recommendedBG(), name: "NEWS_REC_NAME".loc, callback: self.mBlock, tapped: { [weak self] in
            self?.navigationController?.pushViewController(RecommendedVC(), animated: true)
        }),
        NewsTile(image: .upcomming(), name: "NEWS_UP_NAME".loc, callback: self.mBlock, tapped: { [weak self] in
            self?.navigationController?.pushViewController(UpcommingVC(), animated: true)
        }),
    ]
    
    private lazy var mCallback: Holiday.Callback = Holiday.Callback { [weak self] (h: Holiday.Container?, c: Int) in
        if let h = h, c == 200 {
            self?.mTiles[0].count = UInt64(h.today.count)
            self?.mTiles[1].count = UInt64(h.recommended.count)
            self?.mTiles[2].count = UInt64(h.upcoming.count)
            
            self?.mTiles[0].ui = h.uiToday
            self?.mTiles[1].ui = h.uiRecommended
            self?.mTiles[2].ui = h.uiUpcoming
        } else {
            self?.mTiles[0].error = true
            self?.mTiles[1].error = true
            self?.mTiles[2].error = true
        }
    }
    
    deinit {
        Holiday.Manager.del(mCallback)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Holiday.Manager.add(mCallback)
        Holiday.Manager.refresh()
        mTiles.enumerated().forEach { (i: Int, e: NewsTile) in
            view.addSubview(e)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let h: CGFloat = view.height / CGFloat(mTiles.count)
        let w: CGFloat = view.width
        mTiles.enumerated().forEach { (i: Int, t: NewsTile) in
            t.frame = CGRect(x: 0, y: CGFloat(i) * h, width: w, height: h)
        }
    }
    
    @objc private func open(sponsor id: UInt64) {
        let hud: HUD? = HUD.show(in: view.window)
        let _ = Service.sponsor(get: id) { (d: Sponsor.Details?, c: Int) in
            hud?.hide(animated: true)
            if let d = d, c == 200, let v = AppDelegate.window {
                SponsorCardFull(details: d).show(in: v)
            } else {
                "CANT_GET_SPONSOR".loc.show(in: AppDelegate.window)
            }
        }
    }
    
}
