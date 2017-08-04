//
//  Location.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 29/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import CoreLocation
import Foundation
import GoogleMaps
import UIKit

extension Notification.Name {
    
    static let LikeDislike: Notification.Name = Notification.Name(rawValue: "LikeDislike")
    
}

extension Notification {
    
    init(place: Place, id: String) {
        self.init(name: .LikeDislike, object: id, userInfo: place.toJSON())
    }
    
    var place: Place {
        get {
            if self.name == .LikeDislike, let p = Place.deserialize(from: self.userInfo as NSDictionary?) {
                return p
            }
            return Place()
        }
    }
    
}

class Place: Obj, Equatable {
    
    
    // MARK: - Bookmark
    // -------------------------------------------------------------------------
    class Bookmark: Obj {
        
        var locations: [Place] = []
        var total: UInt64 = 0
        
        required init() {}
        
    }
    
    // MARK: - List
    // -------------------------------------------------------------------------
    class List: Obj {
        
        var next_page_token: String?
        var results: [Place] = []
        
    }
    
    // MARK: - Details
    // -------------------------------------------------------------------------
    class Details: Obj {
        
        var result: Place = Place()
        
    }

    // MARK: - Observer
    // -------------------------------------------------------------------------
    class Observer {
        
        private weak var mPlace: Place?
        
        var place: Place? {
            return mPlace
        }
        
        var block: (Place)->Void
        
        fileprivate init(place: Place, callback: @escaping (Place)->Void) {
            block  = callback
            mPlace = place
        }
        
        func invalidate() {
            mPlace?.remove(observer: self)
        }
        
    }
    
    // MARK: - Geometry
    // -------------------------------------------------------------------------
    class Geometry: Obj {
        
        class Location: Obj {
            
            var lat: Float?
            var lng: Float?
            
            required init() {}
            
        }

        var location: Location?

        func distance(to: CLLocation?) -> String {
            if let to = to, let f = location, let lat = f.lat, let lng = f.lng {
                let value: CLLocationDistance = CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng)).distance(from: to) / 1609.344
                let dist: String = String(format: "%.02f", value)
                return dist == "1.00" ? ((dist+" ") + "MILE".loc) : (dist+" ") + "MILES".loc
            }
            return "CANT_DETECT_DISTANCE".loc
        }
        
    }
    
    // MARK: - Period
    // -------------------------------------------------------------------------
    class Period: Obj {
        
        class Time: Obj {
            
            var day: Int = 0
            var time: String = "0000"
            
        }
        
        var close: Time = Time()
        var open:  Time = Time()
        
    }
    
    class Hours: Obj {
        
        var periods: [Period] = []

    }

    // MARK: - Enity
    // -------------------------------------------------------------------------
    private var mObservers: [Observer] = []

    var likes:      Int = 0
    var dislikes:   Int = 0
    var checkins:   Int = 0
    var bookmarks:  Int = 0
    var place_id:   String = ""
    var name:       String = ""
    var vicinity:   String?
    var icon:       String?
    var url:        String?
    var geometry:   Geometry?
    var bookmarkId: UInt64?
    var like:       Bool = false
    var dislike:    Bool = false
    var photos:     [String] = []
    
    var formatted_address: String?
    var formatted_phone_number: String?
    var opening_hours: Hours = Hours()
    
    var mapMarker: GMSMarker? {
        if let lat = self.geometry?.location?.lat, let lng = self.geometry?.location?.lng {
            let marker: GMSMarker = GMSMarker(position: CLLocationCoordinate2D(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng)))
            marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
            let img = UIImageView(frame: CGRect(x: 0, y: 0, width: 30.0, height: 30.0))
            img.contentMode = .scaleAspectFit
            marker.iconView = img
            marker.userData = self
            img.sd_setImage(with: URL(string: self.icon?.abs ?? ""))
            return marker
        }
        return nil
    }
    
    var location: CLLocation? {
        if let lat = self.geometry?.location?.lat, let lng = self.geometry?.location?.lng {
            return CLLocation(latitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng))
        }
        return nil
    }
    
    var hours: String {
        var times: [String:[String]] = [:]
        self.opening_hours.periods.forEach({ (p: Place.Period) in
            let df = DateFormatter()
            df.dateFormat = "HHmm"
            if let open = df.date(from: p.open.time), let close = df.date(from: p.close.time) {
                df.dateFormat = "h:mm a"
                let time: String = "\(df.string(from: open)) - \(df.string(from: close))"
                if times[time] == nil {
                    times[time] = []
                }
                times[time]?.append("DAY_\(p.open.day+1)".loc.capitalized)
            }
        })
        
        if times.count > 0 {
            return "OPEN_FROM".loc + " " + (times.flatMap({ (key: String, value: [String]) -> String? in
                return "\(key) \(value[0])" + (value.count > 1 ? (" - \(value[value.count-1])") : "")
            })).joined(separator: ", ")
        }
        return "OPEN_FROM".loc + " " + "UNKNOWN".loc
    }

    required init() {
        super.init()
        NotificationCenter.default.addObserver(self, selector: #selector(likesDislikesChanged(_:)), name: .LikeDislike, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func format(value: Int) -> String {
        switch true {
        case value >= 1000000: return String(format: "%.00f", value) + part(of: value, from: 1000000) + "M"
        case value >= 100000: return String(format: "%.00f", value) + part(of: value, from: 100000) + "kk"
        case value >= 1000: return String(format: "%.00f", value) + part(of: value, from: 1000) + "k"
        default: break
        }
        return "\(value)"
    }
    
    func remove(observer: Observer) {
        if let index = mObservers.index(where: { $0 === observer }) {
            mObservers.remove(at: index)
        }
    }
    
    func observe(callback: @escaping (Place) -> Void) -> Observer {
        let obj = Observer(place: self, callback: callback)
        mObservers.append(obj)
        return obj
    }
    
    private func part(of: Int, from: Int) -> String {
        if from > 0 {
            let tmp: CGFloat = CGFloat(of % from) / CGFloat(from)
            return tmp > 0.01 ? String(format: ".%.02f", tmp) : ""
        }
        return ""
    }
    
    @objc private func likesDislikesChanged(_ notification: Notification) {
        if let id = notification.object as? String, id == place_id {
            let newObj: Place = notification.place
            likes      = newObj.likes
            dislikes   = newObj.dislikes
            like       = newObj.like
            dislike    = newObj.dislike
            checkins   = newObj.checkins
            bookmarks  = newObj.bookmarks
            bookmarkId = newObj.bookmarkId
            mObservers.forEach { (o: Place.Observer) in
                o.block(self)
            }
        }
    }
    
    func notify() {
        NotificationCenter.default.post(Notification(place: self, id: place_id))
    }
    
    // MARK: - Equatable methods
    // -------------------------------------------------------------------------
    static func ==(lhs: Place, rhs: Place) -> Bool {
        return lhs.place_id == rhs.place_id || lhs === rhs
    }
    
}
