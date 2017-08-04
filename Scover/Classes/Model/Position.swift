//
//  Position.swift
//  Scover
//
//  Created by Mobile App Dev on 07/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Foundation
import CoreLocation

class Position: NSObject, CLLocationManagerDelegate {
    
    private var mLocation: CLLocation?
    var coords: CLLocation? {
        return mLocation ?? mManager.location
    }
    
    private lazy var mManager: CLLocationManager = { [weak self] () -> CLLocationManager in
        let tmp: CLLocationManager = CLLocationManager()
        tmp.delegate = self
        return tmp
    }()
    
    private static let mInstance: Position = Position()

    static func shared() -> Position {
        return mInstance
    }
    
    static func isServicesEnabled() -> Bool {
        return !(CLLocationManager.locationServicesEnabled() == false ||
            CLLocationManager.authorizationStatus() == .denied ||
            CLLocationManager.authorizationStatus() == .restricted ||
            CLLocationManager.authorizationStatus() == .notDetermined)
    }
    
    private override init() {}
    
    func start() {
        mManager.requestWhenInUseAuthorization()
        if type(of: self).isServicesEnabled() {
            mManager.startUpdatingLocation()
        }
    }
    
    func stop() {
        mManager.stopUpdatingLocation()
    }
    
    // MARK: - CLLocationManagerDelegate methods
    // -------------------------------------------------------------------------
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        mLocation = locations.last
    }
    
}
