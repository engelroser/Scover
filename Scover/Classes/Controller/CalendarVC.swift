//
//  CalendarVC.swift
//  Scover
//
//  Created by Mobile App Dev on 4/25/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import Alamofire

class CalendarVC: CommonVC, CalendarViewDelegate, HolidaysDelegate {
    
    private var mRequest: DataRequest?
    private var mExtraSpace: CGFloat = 0.0
    
    private lazy var mHolidays: Holidays = Holidays(delegate: self)
    private let mCalendar: CalendarView = CalendarView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "SCOVER".loc
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: Icon.expand.view(size: 20.0, color: .white, target: self, action: #selector(toggle)))
        
        mCalendar.delegate    = self
        mHolidays.withSection = false
        
        mHolidays.addSubview(mCalendar)
        view.addSubview(mHolidays)
        request(date: mCalendar.date)
    }
    
    private func request(date: Date) {
        if mRequest == nil {
            mHolidays.startLoading()
            mRequest = Service.holidays(date: date, callback: { [weak self] (d: [Holiday?]?, c: Int) in
                self?.mRequest = nil
                if c == 200, let d = d {
                    self?.mHolidays.items = d.flatMap({$0})
                    self?.mCalendar.update(count: UInt(self?.mHolidays.items.count ?? 0))
                } else {
                    "HOLIDAYS_LOADING_ERR".show(in: self?.view.window)
                }
                self?.mHolidays.stopLoading()
            })
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mHolidays.frame = view.bounds
        mCalendar.frame = CGRect(x: 0, y: -mCalendar.height, width: view.width, height: mCalendar.height)
        mHolidays.contentInset.top -= mExtraSpace
        mHolidays.contentInset.top += mCalendar.height
        mExtraSpace = mCalendar.height
    }

    @objc private func toggle() {
        let newState: Bool = !self.mCalendar.expand

        UIView.animate(withDuration: 0.2) {
            self.mCalendar.expand = newState
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
            self.mHolidays.setContentOffset(CGPoint(x: 0, y: -self.mHolidays.contentInset.top), animated: false)
        }

        self.navigationItem.setRightBarButtonItems(!newState ? nil : [
            UIBarButtonItem(customView: Icon.right.view(size: 20.0, color: .white, target: self, action: #selector(moveNext))),
            UIBarButtonItem(customView: Icon.left.view(size: 20.0, color: .white, target: self, action: #selector(moveBack)))
        ], animated: true)
    }
    
    @objc private func moveNext() {
        mCalendar.moveMonthNext()
    }
    
    @objc private func moveBack() {
        mCalendar.moveMonthBack()
    }
    
    // MARK: - CalendarViewDelegate methods
    // -------------------------------------------------------------------------
    func changed(date: Date) {
        mRequest?.cancel()
        mRequest = nil
        mHolidays.items = []
        mCalendar.update(count: nil)
        request(date: date)
    }
    
    // MARK: - HolidaysDelegate methods
    // -------------------------------------------------------------------------
    func didScroll(y: CGFloat) {}
    
    func footerVisible() {}
    
    func refreshed() {
        request(date: mCalendar.date)
    }
    
    func show(holiday: Holiday) {
        navigationController?.pushViewController(PlacesVC(for: holiday), animated: true)
    }
    
}
