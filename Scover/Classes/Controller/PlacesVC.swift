//
//  Locations.swift
//  Scover
//
//  Created by Mobile App Dev on 5/5/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import Alamofire

class PlacesVC: CommonVC, PlacesDelegate {

    private var mRequest: DataRequest?
    private var mExtraSpace: CGFloat = 0.0
    
    private let mHUD:  UIActivityIndicatorView = .whiteLarge
    private var mNext: String?

    private lazy var mBanner: HolidayBanner = HolidayBanner(with: self.mHoliday, block: { [weak self] () -> Void in
        self?.refreshed()
    })
 
    private lazy var mTable: Places = Places(delegate: self)
    
    private let mHoliday: Holiday
    
    init(for holiday: Holiday) {
        mHoliday = holiday
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: Icon.back.view(size: 20.0, color: .white, padding: 4, target: self, action: #selector(back)))
        self.title = "HOLIDAY_LOCATIONS".loc
        mTable.addSubview(mBanner)
        view.addSubview(mTable)
        refreshed()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mTable.frame = view.bounds
        mTable.contentInset.top -= mExtraSpace
        mExtraSpace = mBanner.minHeight(for: mTable.width)
        mTable.contentInset.top += mExtraSpace
        didScroll(y: mTable.contentOffset.y)
    }

    // MARK: - PlacesDelegate methods
    // -------------------------------------------------------------------------
    func didScroll(y: CGFloat) {
        let minH: CGFloat = mBanner.minHeight(for: mTable.width)
        mBanner.frame = CGRect(x: 0, y: min(y, -minH), width: mTable.width, height: minH - min(y + minH, 0.0))
    }
    
    func footerVisible() {
        if mRequest == nil, let token = mNext {
            mRequest = Service.locations(for: mHoliday.id, next: token, callback: { [weak self] (p: Place.List?, c: Int) in
                if let p = p, c == 200 {
                    var items: [Place] = self?.mTable.items ?? []
                    items.append(contentsOf: p.results)
                    self?.mTable.items = items
                    self?.mNext = p.next_page_token
                    if self?.mNext != nil {
                        self?.mTable.tableFooterView = self?.mHUD
                    } else {
                        self?.mTable.tableFooterView = nil
                    }
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
        if let index = mBanner.selected, index < mHoliday.categories.count, let coords = Position.shared().coords {
            mTable.startLoading()
            let category: Category = mHoliday.categories[index]
            mRequest?.cancel()
            mRequest = Service.locations(for: mHoliday.id, position: coords.coordinate, categoryID: category.id, callback: { [weak self] (p: Place.List?, c: Int)->Void in
                if let p = p, c == 200 {
                    self?.mTable.iconURL = category.activeUrl
                    self?.mTable.items   = p.results
                    self?.mNext = p.next_page_token
                    self?.mTable.tableFooterView = self?.mNext != nil ? self?.mHUD : nil
                } else {
                    "PLACES_ERROR_LOADING".loc.show(in: UIApplication.shared.windows.first)
                }
                self?.mTable.stopLoading()
                self?.mRequest = nil
            })
            
        } else {
            if Position.shared().coords == nil {
                "CAN_GET_LOCATION".loc.show(in: UIApplication.shared.windows.first)
            }
            mTable.stopLoading()
        }
    }

    func show(place: Place) {
        navigationController?.pushViewController(DetailsVC(for: place), animated: true)
    }

}
