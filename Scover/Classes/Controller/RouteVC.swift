//
//  RouteVC.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 21/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import GoogleMaps

class RouteVC: CommonVC {

    private let mMap: GMSMapView = { () -> GMSMapView in
        let tmp: GMSMapView = GMSMapView(frame: UIScreen.main.bounds)
        tmp.isMyLocationEnabled      = true
        tmp.settings.rotateGestures  = false
        tmp.settings.tiltGestures    = false
        if let style = Bundle.main.url(forResource: "style.json", withExtension: nil) {
            tmp.mapStyle = try? GMSMapStyle(contentsOfFileURL: style)
        }
        return tmp
    }()
    
    private let mRoute: Route
    private let mPath:  GMSPath?
    
    init(with r: Route) {
        mRoute = r
        mPath  = mRoute.line != nil ? GMSPath(fromEncodedPath: mRoute.line!) : nil
        super.init(nibName: nil, bundle: nil)
        if let path = mPath, path.count() > 0 {
            let line: GMSPolyline = GMSPolyline(path: path)
            line.strokeColor = .red
            line.strokeWidth = 2.0
            line.geodesic    = true
            line.map = mMap
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "ROUTE_TITLE".loc
        
        if navigationController?.isBeingPresented ?? false {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: Icon.cross.view(size: 20.0, color: .white, padding: 3.0, target: self, action: #selector(close)))
        } else {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: Icon.back.view(size: 20.0, color: .white, padding: 3.0, target: self, action: #selector(back)))
        }
        
        view.addSubview(mMap)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mMap.frame = view.bounds
        if let path = mPath {
            mMap.moveCamera(GMSCameraUpdate.fit(GMSCoordinateBounds(path: path)))
        }
    }
    
}
