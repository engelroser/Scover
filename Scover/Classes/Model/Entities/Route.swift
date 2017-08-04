//
//  Route.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 20/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class Route: Obj {

    enum Mode: Int {
        case car   = 0
        case walk  = 1
        case train = 2
        
        func toString() -> String {
            switch self {
            case .car:   return "driving"
            case .walk:  return "walking"
            case .train: return "transit"
            }
        }
        
    }
    
    class Info: Obj {
        
        class Polyline: Obj {
            var points: String?
        }
        
        class Leg: Obj {
            
            class Distance: Obj {
                var text:  String?
                var value: Float?
            }
            
            class Duration: Obj {
                var text:  String?
                var value: Float?
            }
            
            var distance: Distance?
            var duration: Duration?
            
        }
        
        var legs: [Leg] = []
        var overview_polyline: Polyline?
    }
    
    var routes: [Info] = []
    
    var line: String? {
        return self.routes.first?.overview_polyline?.points
    }
    var distanceMeters: Int {
        if let v: Float = self.routes.first?.legs.first?.distance?.value {
            return Int(ceil(v))
        }
        return 0
    }
    
    var distanceText: String {
        return self.routes.first?.legs.first?.distance?.text ?? ""
    }
    
    var timeSeconds: Int {
        if let v = self.routes.first?.legs.first?.duration?.value {
            return Int(ceil(v))
        }
        return 0
    }
    
    var timeText: String {
        return self.routes.first?.legs.first?.duration?.text ?? ""
    }
    
}
