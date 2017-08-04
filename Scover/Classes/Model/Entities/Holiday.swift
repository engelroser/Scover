//
//  Holiday.swift
//  Scover
//
//  Created by Mobile App Dev on 29/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Alamofire
import Foundation

class Holiday: Obj, Equatable {

    // MARK: - UI
    // -------------------------------------------------------------------------
    class UI: Obj {
        
        var title: String?
        var backgroundUrl: String?
        var description: String?
        var sponsors: [Sponsor] = []
        
    }
    
    // MARK: - Container
    // -------------------------------------------------------------------------
    class Container: Obj {
        
        var today: [Holiday] = []
        var upcoming: [Holiday] = []
        var recommended: [Holiday] = []
        
        var uiToday: UI = UI()
        var uiUpcoming: UI = UI()
        var uiRecommended: UI = UI()
        
    }
    
    // MARK: - Callback
    // -------------------------------------------------------------------------
    class Callback {
        
        let callback: (Holiday.Container?, Int)->Void
        
        init(_ callback: @escaping (Holiday.Container?, Int)->Void) {
            self.callback = callback
        }
        
    }
    
    // MARK: - Manager
    // -------------------------------------------------------------------------
    class Manager {
        
        private static var mRequest:   DataRequest?
        private static var mHolidays:  Holiday.Container?
        private static var mCallbacks: [Holiday.Callback] = []
        
        static var isRunnig: Bool {
            return mRequest != nil
        }
        
        static var holidays: Holiday.Container? {
            return mHolidays
        }
        
        static func add(_ callback: Holiday.Callback) {
            DispatchQueue.main.async {
                if self.mCallbacks.index(where: { $0 === callback }) == nil {
                    self.mCallbacks.append(callback)
                }
            }
        }
        
        static func del(_ callback: Holiday.Callback) {
            DispatchQueue.main.async {
                if let index = self.mCallbacks.index(where: { $0 === callback }) {
                    self.mCallbacks.remove(at: index)
                }
            }
        }
        
        static func refresh() {
            DispatchQueue.main.async {
                if self.mRequest == nil {
                    self.mRequest = Service.holidays(today: { (t: Holiday.Container?, c: Int) in
                        self.mRequest = nil
                        notify(holidays: t, code: c)
                    })
                }
            }
        }
        
        static func notify(holidays: Holiday.Container?, code: Int) {
            if holidays != nil {
                mHolidays = holidays
            }
            mCallbacks.forEach { (c: Holiday.Callback) in
                c.callback(holidays, code)
            }
        }
        
    }

    // MARK: - Bookmark
    // -------------------------------------------------------------------------
    class List: Obj {
        
        var holidays: [Holiday] = []
        var total: UInt64 = 0
        
    }
    
    // MARK: - Entity
    // -------------------------------------------------------------------------
    var id:   UInt64 = 0
    var date: String?
    var name: String?
    var url:  String?
    var backgroundUrl: String?
    var bannerUrl:     String?
    var description:   String?
    var categories:    [Category] = []
    var sponsors:      [Sponsor] = []
    var bookmarkId:    UInt64?

    func dateObj() -> Date? {
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        if let d = date {
            return df.date(from: d)
        }
        return nil
    }
    
    func dateStr() -> String {
        let df: DateFormatter = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        if let d = date, let dateObj = df.date(from: d) {
            let cal: Calendar = Calendar.current
            
            let month: Int = cal.component(.month, from: dateObj)
            let wday:  Int = cal.component(.weekday, from: dateObj)
            let year:  Int = cal.component(.year, from: dateObj)

            return "WEEKDAY_\(wday)".loc+" \(cal.component(.day, from: dateObj)) "+"MONTH_\(month)".loc+" \(year)"
        }
        return ""
    }
    
    static func ==(lhs: Holiday, rhs: Holiday) -> Bool {
        return lhs.id == rhs.id || lhs === rhs
    }
    
}
