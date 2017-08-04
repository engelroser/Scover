//
//  Photo.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 21/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Foundation

class Photo: Obj {
    
    class Container: Obj {
        
        var photos: [Photo] = []
        var total:  UInt64? = 0
        
    }
    
    var imgUrl: String?
    var id: UInt64?
    
}
