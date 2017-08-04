//
//  Profile.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 27/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Foundation

class Profile: Obj {
    
    class Photo: Obj {
        var imgUrl:   String?
        var location: Place?
    }
    
    class Checkin: Obj {
        var createdAt: String?
        var location:  Place?
        
        var createdAtObj: Date? {
            if let t = createdAt {
                let df: DateFormatter = DateFormatter()
                df.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
                return df.date(from: t)
            }
            return nil
        }
        
    }
    
    var firstName: String?
    var lastName:  String?
    var email:     String?
    var checkins:  UInt64 = 0
    var photos:    UInt64 = 0
    var likes:     UInt64 = 0
    var avatar:    String?
    
}
