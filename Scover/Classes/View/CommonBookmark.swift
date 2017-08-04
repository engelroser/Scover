//
//  CommonBookmark.swift
//  Scover
//
//  Created by Mobile App Dev on 09/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Alamofire
import UIKit

class CommonBookmark<K: Equatable, C: CommonCell, H: UITableViewHeaderFooterView>: UIView, SearchDelegate, TableDelegate {
    
    private var mHUD: UIActivityIndicatorView = .whiteLarge
    private var mRequest:  DataRequest?
    private var mMaxCount: UInt64 = UInt64.max
    
    private lazy var mTable: CommonTable<K, C, H> = self.generateTable()
    private lazy var mSearch: SearchField = SearchField(delegate: self)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mSearch)
        addSubview(mTable)
        refreshed()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mSearch.frame = CGRect(x: 0, y: 0, width: width, height: 46)
        mTable.frame  = CGRect(x: 0, y: mSearch.maxY, width: width, height: height-mSearch.maxY)
    }
    
    func loadFromStart(search: String?) {
        mTable.items = []
        mTable.startLoading()
        load(search: search)
    }
    
    func load(search: String?, offset: UInt64 = 0) {
        if mTable.items.count == 0 {
            mTable.tableFooterView = nil
            mTable.startLoading()
        }
        mRequest?.cancel()
        mRequest = doRequest(search: search ?? "", offset: offset, limit: 20, block: { [weak self] (p: [K]?, c: Int, t: UInt64?) in
            if c == 200, let p = p, let t = t {
                self?.mMaxCount = t
                if offset == 0 {
                    self?.mTable.items = p
                } else {
                    self?.mTable.items.append(contentsOf: p)
                }
                self?.mTable.tableFooterView = UInt64(self?.mTable.items.count ?? 0) < t ? self?.mHUD : nil
            } else {
                "CANT_LOAD_BOOKMAKR".loc.show(in: self?.window)
            }
            self?.mTable.stopLoading()
        })
    }
    
    func doRequest(search: String, offset: UInt64, limit: UInt64, block: @escaping ([K]?, Int, UInt64?)->Void) -> DataRequest? {
        return nil
    }
    
    func generateTable() -> CommonTable<K, C, H> {
        let tmp: CommonTable<K, C, H> = CommonTable<K, C, H>()
        tmp.tableDelegate = self
        return tmp
    }
    
    // MARK: - TableDelegate methods
    // -------------------------------------------------------------------------
    func didScroll(y: CGFloat) {}
    
    func footerVisible() {
        if UInt64(mTable.items.count) < mMaxCount {
            load(search: mSearch.text, offset: UInt64(mTable.items.count))
        } else {
            mTable.tableFooterView = nil
        }
    }
    
    func refreshed() {
        load(search: mSearch.text)
    }
    
    // MARK: - SearchDelegate methods
    // -------------------------------------------------------------------------
    func search(text: String?) {
        loadFromStart(search: text)
    }
    
    func search(start: Bool) {}
    
}
