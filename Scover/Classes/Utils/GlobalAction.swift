//
//  Sharer.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 12/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import EventKit
import FBSDKShareKit
import CoreLocation

class GlobalAction {
    
    static func share(place: Place?) {
        if let url = place?.url, let vc = UIApplication.shared.delegate?.window??.rootViewController {
            vc.present(UIActivityViewController(activityItems: [url], applicationActivities: nil), animated: true)
        }
    }
    
    static func share(holiday: Holiday?) {
        if let url = holiday?.url, let vc = UIApplication.shared.delegate?.window??.rootViewController {
            vc.present(UIActivityViewController(activityItems: [url], applicationActivities: nil), animated: true)
        }
    }
    
    static func bookmark(place: Place?) {
        guard let id = place?.place_id else { return }
        let hud: HUD? = HUD.show(in: AppDelegate.window)
        let _ = Service.bookmarkPlaces(add: id, callback: { (b: Bookmark?, c: Int) in
            hud?.hide(animated: true)
            NotificationCenter.default.post(name: .BookmarkNeedUpdatePlace, object: nil)
            (c == 200 ? "BOOKMARK_ADDED" : "CANT_ADD_BOOKMARK").loc.show(in: AppDelegate.window)
            if let b = b, let p = place {
                p.bookmarks  = p.bookmarks + 1
                p.bookmarkId = b.id
                p.notify()
            }
        })
    }
    
    static func bookmark(holiday: UInt64?) {
        guard let holiday = holiday else { return }
        let hud: HUD? = HUD.show(in: AppDelegate.window)
        let _ = Service.bookmarkHolidays(add: holiday, callback: { (_, c: Int) in
            hud?.hide(animated: true)
            (c == 200 ? "BOOKMARK_ADDED" : "CANT_ADD_BOOKMARK").loc.show(in: AppDelegate.window)
            if c == 200 {
                NotificationCenter.default.post(name: .BookmarkNeedUpdateHoliday, object: nil)
            }
        })
    }
    
    static func delete(bookmark p: Place?, done: @escaping (Bool)->Void) {
        delete(bookmark: p?.bookmarkId, done: { (r: Bool)->Void in
            done(r)
            if r {
                p?.bookmarkId = nil
                p?.bookmarks  = max((p?.bookmarks ?? 0) - 1, 0)
                p?.notify()
                NotificationCenter.default.post(name: .BookmarkNeedUpdatePlace, object: nil)
            }
        });
    }
    
    static func delete(bookmark h: Holiday?, done: @escaping (Bool)->Void) {
        delete(bookmark: h?.bookmarkId, done: { (r: Bool)->Void in
            done(r)
            if r {
                NotificationCenter.default.post(name: .BookmarkNeedUpdateHoliday, object: nil)
            }
        });
    }
    
    static func route(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, mode: Route.Mode = .walk, done: @escaping (Route)->Void) {
        let hud: HUD? = HUD.show(in: AppDelegate.window)
        let _ = Service.route(from: from, to: to, mode: mode) { (r: Route?, c: Int) in
            hud?.hide(animated: true)
            if c == 200, let r = r {
                done(r)
            } else {
                "CANT_GET_ROUTE".loc.show(in: AppDelegate.window)
            }
        }
    }
 
    static func delete(bookmark: UInt64?, done: @escaping (Bool)->Void) {
        if let id = bookmark {
            let hud: HUD? = HUD.show(in: AppDelegate.window)
            let _ = Service.bookmarkDelete(id: id, callback: { (_, c: Int) in
                hud?.hide(animated: true)
                done(c == 200)
            })
        } else {
            "CANT_DELETE_BOOKMARK".loc.show(in: AppDelegate.window)
        }
    }
    
    static func place(_ p: Place, like: Bool) {
        let hud: HUD? = HUD.show(in: AppDelegate.window)
        let _ = Service.place(id: p.place_id, like: like, callback: { (_, c: Int) in
            hud?.hide(animated: true)
            if c == 200 {
                if like {
                    p.like  = true
                    p.likes += 1
                    p.dislike  = false
                    p.dislikes = max(0, p.dislikes-1)
                } else {
                    p.dislike  = true
                    p.dislikes += 1
                    p.like  = false
                    p.likes = max(0, p.likes-1)
                }
                p.notify()
                NotificationCenter.default.post(name: .ProfileUpdated, object: nil)
            } else {
                (like ? "LIKE_ERROR" : "DISLIKE_ERROR").loc.show(in: AppDelegate.window)
            }
        })
    }
    
    static func check(in place: Place?) {
        if let id = place?.place_id {
            let hud: HUD? = HUD.show(in: AppDelegate.window)
            let _ = Service.check(in: id, callback: { (r: Bool) in
                hud?.hide(animated: true)
                if r, let p = place {
                    p.checkins += 1
                    p.notify()
                    NotificationCenter.default.post(name: .ProfileUpdated, object: nil)
                } else if !r {
                    "CHECKIN_ERROR".loc.show(in: AppDelegate.window)
                }
            })
        }
    }
    
    static func alarm(holiday: Holiday) {
        let hud: HUD? = HUD.show(in: AppDelegate.window)
        let _ = Service.holiday(alarm: holiday) { (r: Bool) in
            hud?.hide(animated: true)
            (r ? "ALARM_DONE" : "CANT_ALARM").loc.show(in: AppDelegate.window)
        }
    }
    
}
