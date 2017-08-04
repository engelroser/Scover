//
//  BookmarkHolidaysView.swift
//  Scover
//
//  Created by Mobile App Dev on 09/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Alamofire
import UIKit

protocol BookmarkHolidaysViewDelegate: class {
    func tapped(holiday: Holiday)
}

class BookmarkHolidaysView: CommonBookmark<Holiday, HolidayCell, TodayHeader>, HolidaysDelegate {
    
    private weak var mDelegate: BookmarkHolidaysViewDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(delegate: BookmarkHolidaysViewDelegate? = nil) {
        super.init(frame: .zero)
        mDelegate = delegate
    }
    
    override func generateTable() -> CommonTable<Holiday, HolidayCell, TodayHeader> {
        return Holidays(delegate: self, actions: [.bell, .share, .cross])
    }
    
    override func doRequest(search: String, offset: UInt64, limit: UInt64, block: @escaping ([Holiday]?, Int, UInt64?) -> Void) -> DataRequest? {
        return Service.bookmarkHolidays(search: search, offset: offset, limit: limit, callback: { (p: Holiday.List?, c: Int) in
            block(p?.holidays, c, p?.total)
        })
    }
    
    // MARK: - HolidaysDelegate methods
    // -------------------------------------------------------------------------
    func show(holiday: Holiday) {
        mDelegate?.tapped(holiday: holiday)
    }
    
}
