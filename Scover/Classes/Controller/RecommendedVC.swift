//
//  RecommendedVC.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/3/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import Alamofire
import UIKit

class RecommendedVC: CommonVC, PlacesDelegate {

    private let mHUD:      UIActivityIndicatorView = .whiteLarge
    private var mNext:     String?
    private var mRequest:  DataRequest?
    
    private lazy var mHeader: HolidaysHorizontal = HolidaysHorizontal(page: { [weak self] (page: Int) in
        self?.refreshed()
    }, category: { [weak self] (c: Category) in
        self?.refreshed()
    })
    
    private lazy var mTable: Places = Places(delegate: self, header: self.mHeader)
    
    private lazy var mCallback: Holiday.Callback = Holiday.Callback { [weak self] (h: Holiday.Container?, c: Int) in
        guard let s = self else { return }
        if let h = h?.recommended, c == 200 {
            s.mHeader.items = h
            if h.count > 0 {
                s.refreshed()
            } else {
                s.mTable.stopLoading()
            }
        } else {
            s.mTable.stopLoading()
            "ERROR_LOAD_RECOM".show(in: s.view.window)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "RECOMMENDED".loc
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: Icon.back.view(size: 20.0, color: .white, padding: 4, target: self, action: #selector(back)))
        view.addSubview(mTable)
        
        Holiday.Manager.add(mCallback)
        if let holidays = Holiday.Manager.holidays?.recommended, holidays.count > 0 {
            mHeader.items = holidays
        } else {
            Holiday.Manager.refresh()
            mTable.startLoading()
        }
    }
    
    deinit {
        Holiday.Manager.del(mCallback)
        mRequest?.cancel()
        mRequest = nil
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mTable.frame = view.bounds
    }
    
    // MARK: - PlacesDelegate methods
    // -------------------------------------------------------------------------
    func didScroll(y: CGFloat) {}
    
    func footerVisible() {
        if mRequest == nil, let token = mNext, let holiday = mHeader.holiday {
            mRequest = Service.locations(for: holiday.id, next: token, callback: { [weak self] (p: Place.List?, c: Int) in
                if let p = p, c == 200 {
                    var items: [Place] = self?.mTable.items ?? []
                    items.append(contentsOf: p.results)
                    self?.mTable.items = items
                    self?.mNext = p.next_page_token
                    self?.mTable.tableFooterView = self?.mNext != nil ? self?.mHUD : nil
                } else {
                    "PLACES_ERROR_LOADING".loc.show(in: UIApplication.shared.windows.first)
                }
                self?.mRequest = nil
            })
        } else if mNext == nil {
            mTable.tableFooterView = nil
        }
    }
    
    func refreshed() {
        mRequest?.cancel()
        mRequest = nil
        
        if (Holiday.Manager.holidays?.recommended.count ?? 0) == 0 {
            Holiday.Manager.refresh()
        } else if let holiday = mHeader.holiday, let category = mHeader.category, let coords = Position.shared().coords?.coordinate {
            mTable.startLoading()
            mRequest = Service.locations(for: holiday.id, position: coords, categoryID: category.id, callback: { [weak self] (places: Place.List?, c: Int) in
                if c == 200, let p = places {
                    self?.mTable.iconURL = category.activeUrl
                    self?.mTable.items   = p.results
                    self?.mNext = p.next_page_token
                    self?.mTable.tableFooterView = self?.mNext != nil ? self?.mHUD : nil
                } else {
                    "PLACES_ERROR_LOADING".loc.show(in: self?.view.window)
                }
                self?.mRequest = nil
                self?.mTable.stopLoading()
            })
        } else {
            if Position.shared().coords == nil {
                "CAN_GET_LOCATION".loc.show(in: view.window)
            }
            mTable.stopLoading()
        }
    }
    
    func show(place: Place) {
        navigationController?.pushViewController(DetailsVC(for: place), animated: true)
    }
    
}
