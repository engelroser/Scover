//
//  Sponsor.swift
//  Scover
//
//  Created by Mobile App Dev on 30/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Foundation

class Sponsor: Obj {
    
    class Link: Obj {
        var name: String?
        var url:  String?
    }

    class Details: Obj {
        var id: UInt64 = 0
        var logoUrl: String?
        var name: String?
        var description: String?
        var links: [Link] = []
        var media: [String] = []
    }
    
    var logoUrl: String?
    var id: UInt64 = 0
    var name: String?
    
}
