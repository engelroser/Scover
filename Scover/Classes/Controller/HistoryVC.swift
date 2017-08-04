//
//  HistoryVC.swift
//  Scover
//
//  Created by Mobile App Dev on 26/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Alamofire
import UIKit

class HistoryVC: CommonVC, HolidaysDelegate {
    
    private let mHUD: UIActivityIndicatorView = .white
    private var mCount: UInt64 = UInt64.max
    private var mRequest: DataRequest?
    private lazy var mTable: Holidays = Holidays(delegate: self)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: Icon.back.view(size: 20.0, color: .white, padding: 4, target: self, action: #selector(back)))
        self.title = "HOLIDAY_HISTORY".loc
        view.addSubview(mTable)
        load(clear: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mTable.frame = view.bounds
    }
    
    private func load(clear: Bool = false) {
        if clear || (mRequest == nil && UInt64(mTable.items.count) < mCount) {
            
            if clear {
                mTable.startLoading()
                UIView.animate(withDuration: 0.25, animations: { 
                    self.mTable.tableFooterView = nil
                })
            }
            
            mRequest?.cancel()
            mRequest = Service.holidays(passed: UInt64(clear ? 0 : mTable.items.count), callback: { [weak self] (l: Holiday.List?, c: Int) in
                guard let s = self else { return }
                if let l = l, c == 200 {
                    s.mCount = l.total
                    if clear {
                        s.mTable.items = l.holidays
                    } else {
                        s.mTable.items.append(contentsOf: l.holidays)
                    }
                    s.mTable.tableFooterView = UInt64(s.mTable.items.count) < s.mCount ? s.mHUD : nil
                } else {
                    "CANT_LOAD_HOLIDAYS".loc.show(in: s.view.window)
                }
                
                s.mRequest = nil
                s.mTable.stopLoading()
            })
        }
    }
    
    deinit {
        mRequest?.cancel()
        mRequest = nil
    }
    
    
    // MARK: - HolidaysDelegate methods
    // -------------------------------------------------------------------------
    func show(holiday: Holiday) {
        navigationController?.pushViewController(PlacesVC(for: holiday), animated: true)
    }
    
    func didScroll(y: CGFloat) {}
    
    func footerVisible() {
        load()
    }
    
    func refreshed() {
        load(clear: true)
    }
    
}
