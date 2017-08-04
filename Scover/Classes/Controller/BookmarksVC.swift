//
//  BookmarksVC.swift
//  Scover
//
//  Created by Mobile App Dev on 4/25/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import Alamofire
import UIKit

class BookmarksVC: CommonVC, BookmarkHolidaysViewDelegate, BookmarkPlacesViewDelegate {
    
    private lazy var mSwitcher: UIView = { [weak self] () -> UIView in
        let tmp: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 232.0, height: 44.0))

        let l: UILabel = UILabel.label(font: UIFont.josefinSansBold(20.0), text: "HOLIDAYS".loc, lines: 1, color: .white, alignment: .left)
        l.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showHolidays)))
        l.frame = CGRect(x: 0, y: 0, width: tmp.width/2.0, height: tmp.height)
        l.isUserInteractionEnabled = true
        tmp.addSubview(l)
        
        let r: UILabel = UILabel.label(font: UIFont.josefinSansBold(20.0), text: "PLACES".loc, lines: 1, color: .white, alignment: .right)
        r.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showPlaces)))
        r.frame = CGRect(x: tmp.width/2.0, y: 0, width: tmp.width/2.0, height: tmp.height)
        r.isUserInteractionEnabled = true
        tmp.addSubview(r)
        
        return tmp
    }()
    
    private let mViewHolidays: UILabel = .label(font: .regular(12.0), text: "VIEW_HISTORY".loc, lines: 1, color: .white, alignment: .center)

    private lazy var mHolidays: BookmarkHolidaysView = BookmarkHolidaysView(delegate: self)
    private lazy var mPlaces:   BookmarkPlacesView   = BookmarkPlacesView(delegate: self)

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        subscribe()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mViewHolidays.backgroundColor = UIColor.black.withAlphaComponent(0.25)
        mViewHolidays.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(viewHoliday)))
        self.navigationItem.titleView = mSwitcher
        view.backgroundColor = .darkBG
        showHolidays()
    }
    
    override func isGgradien() -> Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        
        NotificationCenter.default.removeObserver(self, name: .BookmarkNeedUpdateHoliday, object: nil)
        NotificationCenter.default.removeObserver(self, name: .BookmarkNeedUpdatePlace, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillAppear(animated)
        subscribe()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mViewHolidays.frame = CGRect(x: 0, y: view.height-46.0, width: view.width, height: 46.0)
        mHolidays.frame = CGRect(x: 0, y: 0, width: view.width, height: mViewHolidays.minY)
        mPlaces.frame = view.bounds
    }
    
    private func subscribe() {
        NotificationCenter.default.addObserver(self, selector: #selector(refreshedHolidays), name: .BookmarkNeedUpdateHoliday, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(refreshedPlaces), name: .BookmarkNeedUpdatePlace, object: nil)
    }
    
    @objc private func refreshedPlaces() {
        mPlaces.refreshed()
    }
    
    @objc private func refreshedHolidays() {
        mHolidays.refreshed()
    }
    
    @objc private func showHolidays() {
        guard mSwitcher.subviews.count >= 2 else { return }
        mSwitcher.subviews[0].alpha = 1.0
        mSwitcher.subviews[1].alpha = 0.5
        mPlaces.removeFromSuperview()
        view.addSubview(mHolidays)
        view.addSubview(mViewHolidays)
    }
    
    @objc private func showPlaces() {
        guard mSwitcher.subviews.count >= 2 else { return }
        mSwitcher.subviews[0].alpha = 0.5
        mSwitcher.subviews[1].alpha = 1.0
        mHolidays.removeFromSuperview()
        mViewHolidays.removeFromSuperview()
        view.addSubview(mPlaces)
    }
    
    @objc private func viewHoliday() {
        navigationController?.pushViewController(HistoryVC(), animated: true)
    }
    
    // MARK: - BookmarkHolidaysViewDelegate methods
    // -------------------------------------------------------------------------
    func tapped(holiday: Holiday) {
        navigationController?.pushViewController(PlacesVC(for: holiday), animated: true)
    }
    
    // MARK: - BookmarkPlacesViewDelegate methods
    // -------------------------------------------------------------------------
    func tapped(place: Place) {
        navigationController?.pushViewController(DetailsVC(for: place), animated: true)
    }
    
}
