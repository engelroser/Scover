//
//  Holidays.swift
//  Scover
//
//  Created by Mobile App Dev on 5/6/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

protocol HolidaysDelegate: TableDelegate {
    func show(holiday: Holiday)
}

class Holidays: CommonTable<Holiday, HolidayCell, TodayHeader> {
    
    private weak var mDelegate: HolidaysDelegate?
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(delegate: HolidaysDelegate? = nil, actions: [Icon] = [.bell, .bookmark, .share], header: UIView? = nil) {
        super.init(delegate: delegate, actions: actions)
        mDelegate = delegate
        self.actionCallback = { [weak self] (i: Icon, h: Holiday) in
            if i == .share {
                GlobalAction.share(holiday: h)
            } else if i == .bookmark {
                GlobalAction.bookmark(holiday: h.id)
            } else if i == .cross {
                GlobalAction.delete(bookmark: h.bookmarkId, done: { [weak self] (r: Bool) in
                    if r {
                        self?.delete(item: h)
                    } else {
                        "CANT_DELETE_BOOKMARK".loc.show(in: AppDelegate.window)
                    }
                })
            } else if i == .bell {
                GlobalAction.alarm(holiday: h)
            }
        }
        self.tapCallback = { [weak self] (h: Holiday) in
            self?.mDelegate?.show(holiday: h)
        }
    }
    
    override func configure(cell: HolidayCell, for item: Holiday) {
        cell.attach(holiday: item)
    }
    
    override func configure(header: TodayHeader, for items: [Holiday]) -> TodayHeader {
        return header.attach(date: items.first?.dateStr(), count: UInt(items.count))
    }
    
    override func split(items: [Holiday]) -> [[Holiday]] {
        var sections: [[Holiday]] = []
        var last: [Holiday] = []
        items.enumerated().forEach { (offset: Int, element: Holiday) in
            if offset == 0 {
                last = []
            } else if let prx = items[offset-1].date, let cur = items[offset].date, cur != prx {
                sections.append(last)
                last = []
            }
            last.append(element)
        }
        if last.count > 0 {
            sections.append(last)
        }
        return sections
    }
    
}
