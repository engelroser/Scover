//
//  Network.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 29/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Foundation
import Alamofire
import HandyJSON
import CoreLocation

typealias Empty = Obj

extension HandyJSON {
    
    private static func put(request: DataRequest, inside block: @escaping (DefaultDataResponse)->Void) -> DataRequest {
        request.response { (r: DefaultDataResponse) in
            if let error: NSError = r.error as NSError?, error.code == URLError.Code.cancelled.rawValue {
                return
            } else {
                if (r.response?.statusCode ?? 0) == 401 || (r.response?.statusCode ?? 0) == 403 {
                    AppDelegate.logout()
                }
                block(r)
            }
        }
        return request
    }
    
    static func action(_ method: HTTPMethod = .get, url: String, params: Parameters? = nil, callback: ((Self?, Int) -> Void)? = nil) -> DataRequest {
        return put(request: Alamofire.request(url.abs, method: method, parameters: params, encoding: JSONEncoding(), headers: Service.headers), inside: { (r: DefaultDataResponse) in
            callback?(Self.deserialize(from: .from(data: r.data)), r.response?.statusCode ?? 0)
        })
    }
    
    static func action(_ method: HTTPMethod = .get, url: String, params: Parameters? = nil, callback: (([Self?]?, Int) -> Void)? = nil) -> DataRequest {
        return put(request: Alamofire.request(url.abs, method: method, parameters: params, encoding: JSONEncoding(), headers: Service.headers), inside: { (r: DefaultDataResponse) in
            callback?([Self].deserialize(from: .from(data: r.data)), r.response?.statusCode ?? 0)
        })
    }
}

class Service {
    
    static var headers: [String: String] {
        var headers: [String: String] = ["Content-Type": "application/json"]
        if let t = Settings.authToken {
            headers["X-Auth-Token"] = t
        }
        if let t = Settings.pushToken {
            headers["X-Push-Token"] = t
        }
        return headers
    }
    
    static func signin(fbToken token: String, callback: @escaping (Auth?, Int)->Void) -> DataRequest {
        return Auth.action(.post, url: "/signin", params: ["fbtoken": token], callback: callback)
    }
    
    static func signin(gToken token: String, callback: @escaping (Auth?, Int)->Void) -> DataRequest {
        return Auth.action(.post, url: "/signin", params: ["gtoken": token], callback: callback)
    }
    
    static func signin(email: String, password: String, callback: @escaping (Auth?, Int)->Void) -> DataRequest {
        return Auth.action(.post, url: "/signin", params: ["email": email, "password": password], callback: callback)
    }
    
    static func signup(email: String, password: String, first: String, last: String, callback: @escaping (Auth?, Int)->Void) -> DataRequest {
        return Auth.action(.post, url: "/signup", params: ["email"     : email,
                                                           "password"  : password,
                                                           "firstName" : first,
                                                           "lastName"  : last], callback: callback)
    }
    
    static func holidays(passed offset: UInt64 = 0, callback: @escaping (Holiday.List?, Int)->Void) -> DataRequest {
        return Holiday.List.action(.get, url: "/api/holidays?passed&offset=\(offset)&limit=20", callback: callback)
    }
    
    static func holidays(today callback: @escaping (Holiday.Container?, Int)->Void) -> DataRequest {
        return Holiday.Container.action(.get, url: "/api/holidays?today", callback: callback)
    }
    
    static func holidays(date: Date, callback: @escaping ([Holiday?]?, Int)->Void) -> DataRequest {
        return Holiday.action(.get, url: "/api/holidays?date1=\(date.searchFormat)&date2=\(date.searchFormat)", callback: callback)
    }
    
    static func holidays(from: Date, to: Date, callback: @escaping ([Holiday?]?, Int)->Void) -> DataRequest {
        return Holiday.action(.get, url: "/api/holidays?date1=\(from.searchFormat)&date2=\(to.searchFormat)", callback: callback)
    }
    
    static func restore(email: String, callback: @escaping (Empty?, Int)->Void) -> DataRequest {
        return Empty.action(.post, url: "/passwordreset", params: ["email": email], callback: callback)
    }
    
    static func locations(`for` holidayId: UInt64, position: CLLocationCoordinate2D, categoryID: UInt64, callback: @escaping (Place.List?, Int)->Void) -> DataRequest {
        return Place.List.action(.get, url: "/api/holidays/\(holidayId)/locations?category=\(categoryID)&location=\(position.latitude),\(position.longitude)", params: nil, callback: callback)
    }
    
    static func locations(search: String, holiday: UInt64, category: UInt64, location: CLLocationCoordinate2D, callback: @escaping (Place.List?, Int)->Void) -> DataRequest {
        return Place.List.action(.get, url: "/api/holidays/\(holiday)/locations?category=\(category)&location=\(location.latitude),\(location.longitude)"+(search.characters.count > 0 ? "&search=\(search)" : ""), callback: callback)
    }
    
    static func locations(`for` holidayId: UInt64, next: String, callback: @escaping (Place.List?, Int)->Void) -> DataRequest {
        return Place.List.action(.get, url: "/api/holidays/\(holidayId)/locations?pagetoken=\(next)", params: nil, callback: callback)
    }

    static func bookmarkPlaces(add id: String, callback: @escaping (Bookmark?, Int)->Void) -> DataRequest {
        return Bookmark.action(.post, url: "/api/bookmarks", params: ["placeId": id], callback: callback)
    }
    
    static func bookmarkPlaces(search: String, offset: UInt64, limit: UInt64, callback: @escaping (Place.Bookmark?, Int)->Void) -> DataRequest {
        return Place.Bookmark.action(.get, url: "/api/bookmarks/locations?offset=\(offset)&limit=\(limit)"+(search.characters.count == 0 ? "" : "&search=\(search)"), callback: callback)
    }
    
    static func bookmarkHolidays(add id: UInt64, callback: @escaping (Bookmark?, Int)->Void) -> DataRequest {
        return Bookmark.action(.post, url: "/api/bookmarks", params: ["holiday": id], callback: callback)
    }
    
    static func bookmarkHolidays(search: String, offset: UInt64, limit: UInt64, callback: @escaping (Holiday.List?, Int)->Void) -> DataRequest {
        return Holiday.List.action(.get, url: "/api/bookmarks/holidays?offset=\(offset)&limit=\(limit)"+(search.characters.count == 0 ? "" : "&search=\(search)"), callback: callback)
    }
    
    static func bookmarkDelete(id: UInt64, callback: @escaping (Empty?, Int)->Void) -> DataRequest {
        return Empty.action(.delete, url: "/api/bookmarks/\(id)", callback: callback)
    }
    
    static func place(id: String, like: Bool, callback: @escaping (Empty?, Int)->Void) -> DataRequest {
        return Empty.action(.post, url: "/api/locations/\(id)/"+(like ? "like" : "dislike"), callback: callback)
    }
    
    static func place(id: String, callback: @escaping (Place?)->Void) -> DataRequest {
        return Place.Details.action(.get, url: "/api/locations/\(id)", callback: { (details: Place.Details?, code: Int) in
            if let p = details?.result, code == 200 {
                callback(p)
            } else {
                callback(nil)
            }
        })
    }
    
    static func check(in id: String, callback: @escaping (Bool)->Void) -> DataRequest {
        return Empty.action(.post, url: "/api/locations/\(id)/checkins", callback: { (r: Empty?, code: Int) in
            callback(code == 200)
        })
    }
    
    static func route(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D, mode: Route.Mode, callback: @escaping (Route?, Int)->Void) -> DataRequest {
        return Route.action(url: "https://maps.googleapis.com/maps/api/directions/json?origin=\(from.latitude),\(from.longitude)&destination=\(to.latitude),\(to.longitude)&key=AIzaSyAMG352JyYStiwR_eiQFc-zL8LY0CVlHFs&mode=\(mode.toString())&units=imperial", callback: callback)
    }
    
    static func photos(`for` placeId: String, offset: UInt64, callback: @escaping ([Photo]?, UInt64)->Void) -> DataRequest {
        return Photo.Container.action(url: "/api/locations/\(placeId)/photos?limit=3&offset=\(offset)", callback: { (r: Photo.Container?, c: Int)->Void in
            if c == 200, let r = r {
                callback(r.photos, r.total ?? 0)
            } else {
                callback(nil, 0)
            }
        })
    }
    
    static func photos(add photo: UIImage, to placeId: String, callback: @escaping (Photo?)->Void) -> DataRequest? {
        if let img: String = UIImageJPEGRepresentation(photo, 1.0)?.base64EncodedString() {
            return Photo.action(.post, url: "/api/photos", params: ["placeId": placeId, "imgBase64": "data:image/jpeg;base64,"+img], callback: { (p: Photo?, c: Int) in
                callback(p)
            })
        }
        DispatchQueue.main.async {
            callback(nil)
        }
        return nil
    }
    
    static func profile(get callback: @escaping (Profile?, Int)->Void) -> DataRequest {
        return Profile.action(.get, url: "/api/profile", callback: callback)
    }
    
    static func profile(photos callback: @escaping ([Profile.Photo?]?, Int)->Void) -> DataRequest {
        return Profile.Photo.action(.get, url: "/api/photos", callback: callback)
    }
    
    static func profile(checkins callback: @escaping ([Profile.Checkin?]?, Int)->Void) -> DataRequest {
        return Profile.Checkin.action(.get, url: "/api/checkins", callback: callback)
    }
    
    static func profile(set image: UIImage, callback: @escaping (Bool)->Void) -> DataRequest? {
        if let img: String = UIImageJPEGRepresentation(image, 1.0)?.base64EncodedString() {
            return Empty.action(.put, url: "/api/profile", params: ["imgBase64": "data:image/jpeg;base64,"+img], callback: { (p: Empty?, c: Int) in
                callback(c == 200)
            })
        }
        DispatchQueue.main.async {
            callback(false)
        }
        return nil
    }
    
    static func sponsor(get id: UInt64, with: @escaping (Sponsor.Details?, Int)->Void) -> DataRequest {
        return Sponsor.Details.action(.get, url: "/api/sponsors/\(id)", callback: with)
    }
    
    static func sponsor(like id: UInt64, with: @escaping (Bool)->Void) -> DataRequest {
        return Empty.action(.post, url: "/api/sponsors/\(id)/like", callback: { (r: Empty?, c: Int)->Void in
            with(c == 200)
        })
    }
    
    static func holiday(alarm h: Holiday, callback: @escaping (Bool)->Void) -> DataRequest {
        return Empty.action(.post, url: "/api/holidays/\(h.id)/alarm", callback: { (r: Empty?, c: Int)->Void in
            callback(c == 200)
        })
    }
    
}
