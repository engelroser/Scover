//
//  SmallRouteMap.swift
//  Scover
//
//  Created by Mobile App Dev on 20/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps

class SmallRouteMap: UIView {
        
    private var mPlace: Place?
    var place: Place? {
        get {
            return mPlace
        }
        set {
            mMap.clear()
            mPlace = newValue
            mPlace?.mapMarker?.map = mMap
            if let lat = mPlace?.geometry?.location?.lat, let lng = mPlace?.geometry?.location?.lng {
                mMap.camera = GMSCameraPosition.camera(withLatitude: CLLocationDegrees(lat), longitude: CLLocationDegrees(lng), zoom: 16)
            }
        }
    }
    
    var block: ((Route)->Void)?
    
    private let mMap:  GMSMapView  = { () -> GMSMapView in
        let tmp: GMSMapView = GMSMapView()
        tmp.isMyLocationEnabled      = true
        tmp.settings.rotateGestures  = false
        tmp.settings.tiltGestures    = false
        tmp.isUserInteractionEnabled = false
        if let style = Bundle.main.url(forResource: "style.json", withExtension: nil) {
            tmp.mapStyle = try? GMSMapStyle(contentsOfFileURL: style)
        }
        return tmp
    }()

    private lazy var mRoutes: [MoveType] = [
        MoveType(with: .car, target: self, action: #selector(moveTypeTapped(_:))),
        MoveType(with: .walk, target: self, action: #selector(moveTypeTapped(_:))),
        MoveType(with: .train, target: self, action: #selector(moveTypeTapped(_:)))
    ]
    
    private let mHUD: UIActivityIndicatorView = .whiteLarge
    
    private var mRequest:   DataRequest?
    private var mPolylines: [Route.Mode: Route] = [:]
    private var mRouteObj:  Route?
    private let mOver:      Gradient = Gradient(from: (UIColor.mapGrad, CGPoint(x: 0, y: 0.7)), to: (UIColor.mapGrad.withAlphaComponent(0.0), CGPoint(x: 0, y: 0)))
    private let mLength:    Progress = Progress(with: .greenArc)
    private let mDuration:  Progress = Progress(with: .pinkArc)
    
    private lazy var mRoute: UIView = { [weak self] () -> UIView in
        let tmp: UIImageView = UIImageView(image: .actionBG())
        tmp.isUserInteractionEnabled = true
        tmp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(notify)))
        
        let icon: UILabel = Icon.arrow.view(size: 16.3, color: .white)
        icon.frame = tmp.bounds
        tmp.addSubview(icon)
        
        return tmp
    }()
    
    @objc private func moveTypeTapped(_ sender: UITapGestureRecognizer) {
        if let s = sender.view as? MoveType, let index = mRoutes.index(of: s), let type = Route.Mode(rawValue: index) {
            show(route: mPolylines[type])
            if mPolylines[type] == nil {
                request(route: type)
            }
        }
    }
    
    @objc private func route() {
        let tmp: UIAlertController = UIAlertController(title: nil, message: "Will show map", preferredStyle: .alert)
        tmp.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.window?.rootViewController?.present(tmp, animated: true, completion: nil)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mMap)
        addSubview(mOver)
        mRoutes.forEach { (t: MoveType) in
            addSubview(t)
        }
        addSubview(mRoute)
        addSubview(mLength)
        addSubview(mDuration)
        addSubview(mHUD)
        mHUD.stopAnimating()
        
        show(route: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mMap.frame = self.bounds
        mOver.frame = self.bounds
        mHUD.center = self.bounds.center()
        mRoute.center = CGPoint(x: self.width-48.0, y: self.height-34.0)
        mLength.center = CGPoint(x: 40.0, y: mMap.maxY-30.0)
        mDuration.center = mLength.center.offset(x: 120.0)
        mRoutes.enumerated().forEach { (offset: Int, element: MoveType) in
            element.center = CGPoint(x: self.width - 28.0 - 37.0 * CGFloat(offset), y: 22.0)
        }
    }
    
    private func show(route: Route?) {
        mRouteObj          = route
        mRoute.isHidden    = route == nil
        mLength.isHidden   = mRoute.isHidden
        mDuration.isHidden = mRoute.isHidden
        
        if let r = mRouteObj {
            mDuration.text = r.timeText
            mDuration.progress = CGFloat(r.timeSeconds) / 3600.0
            
            mLength.text = r.distanceText
            mLength.progress = CGFloat(r.distanceMeters) / 1609.0
        }
    }
    
    private func request(route: Route.Mode) {
        mRequest?.cancel()
        mRequest = nil
        mHUD.stopAnimating()
        if let from = Position.shared().coords, let to = mPlace?.location {
            mHUD.startAnimating()
            mRequest = Service.route(from: from.coordinate, to: to.coordinate, mode: route, callback: { [weak self] (r: Route?, c: Int) in
                self?.mRequest = nil
                self?.mHUD.stopAnimating()
                if c == 200, let r = r, r.line != nil {
                    self?.mPolylines[route] = r
                    self?.show(route: r)
                } else {
                    "CANT_GET_ROUTE".loc.show(in: self?.window)
                }
            })
        } else {
            "CANT_DETECT_LOCATION".loc.show(in: self.window)
        }
    }
    
    @objc private func notify() {
        if let r = mRouteObj {
            block?(r)
        }
    }

}
