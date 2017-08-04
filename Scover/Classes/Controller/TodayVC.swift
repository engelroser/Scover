//
//  TodayVC.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 4/26/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import Alamofire
import UIKit

class TodayVC: CommonVC, HolidaysDelegate {
    
    var errorString: String {
        return "ERROR_LOAD_TODAY".loc
    }
    
    private lazy var mTable: Holidays = Holidays(delegate: self)
    
    private lazy var mCallback: Holiday.Callback = Holiday.Callback { [weak self] (h: Holiday.Container?, c: Int) in
        guard let s = self else { return }
        if let h = s.holidays(from: h), c == 200 {
            s.mTable.items = h
        } else {
            s.errorString.show(in: s.view.window)
        }
        s.mTable.stopLoading()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: Icon.back.view(size: 20.0, color: .white, padding: 4, target: self, action: #selector(back)))
        self.title = "TODAY".loc
        view.addSubview(mTable)

        Holiday.Manager.add(mCallback)
        if let holidays = holidays(from: Holiday.Manager.holidays), holidays.count > 0 {
            mTable.items = holidays
        } else {
            Holiday.Manager.refresh()
            mTable.startLoading()
        }
    }
    
    deinit {
        Holiday.Manager.del(mCallback)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mTable.frame = view.bounds
    }
    
    func holidays(from: Holiday.Container?) -> [Holiday]? {
        return from?.today
    }

    // MARK: - HolidaysDelegate methods
    // -------------------------------------------------------------------------
    func didScroll(y: CGFloat) {}
    
    func footerVisible() {}
    
    func refreshed() {
        Holiday.Manager.refresh()
    }
    
    func show(holiday: Holiday) {
        navigationController?.pushViewController(PlacesVC(for: holiday), animated: true)
    }

}
