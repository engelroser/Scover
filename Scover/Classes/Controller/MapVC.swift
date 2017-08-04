//
//  MapVC.swift
//  Scover
//
//  Created by Mobile App Dev on 4/25/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit
import Alamofire
import GoogleMaps

class MapVC: CommonVC, GMSMapViewDelegate, ResultsVCDelegate {
    
    private let mDate: Date = Date()
    
    private var mTimer: Timer?
    private var mHolidaysRequest: DataRequest?
    private let mHolidays: [[Holiday]] = []
    private var mPosition: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    
    private lazy var mFilter: Filter = Filter(origin: CGPoint(x: 6.0, y: 26.0)) { [weak self] (h: Holiday, c: Category?) in
        self?.mActions.select(holiday: h, category: c)
    }
    
    private lazy var mMap: GMSMapView = { [weak self] () -> GMSMapView in
        let tmp: GMSMapView = GMSMapView()
        tmp.isMyLocationEnabled = true
        tmp.setMinZoom(10, maxZoom: 18)
        tmp.settings.rotateGestures = false
        tmp.settings.tiltGestures = false
        tmp.delegate = self
        if let style = Bundle.main.url(forResource: "style.json", withExtension: nil) {
            tmp.mapStyle = try? GMSMapStyle(contentsOfFileURL: style)
        }
        return tmp
    }()
    
    private lazy var mActions: ResultsVC = ResultsVC(date: self.mDate, delegate: self)
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        addChildViewController(mActions)
        loadHolidays()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        if let loc = Position.shared().coords {
            mMap.camera = GMSCameraPosition.camera(withLatitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude, zoom: 16)
        }
        view.addSubview(mMap)
        view.addSubview(mFilter)
        view.addSubview(mActions.view)
        
        mPosition = mMap.camera.target
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mActions.view.frame = view.bounds
        mMap.frame = view.bounds
    }
    
    deinit {
        mHolidaysRequest?.cancel()
        mHolidaysRequest = nil
        
        mTimer?.invalidate()
        mTimer = nil
    }
    
    private func loadHolidays(delay: TimeInterval? = nil) {
        mTimer?.invalidate()
        mTimer = nil
        mHolidaysRequest?.cancel()
        mHolidaysRequest = nil
        
        if let delay = delay, delay > 0 {
            mTimer = Timer.scheduledTimer(withTimeInterval: delay, repeats: false, block: { [weak self] (t: Timer) in
                self?.loadHolidays()
            })
            if let t = mTimer {
                RunLoop.main.add(t, forMode: .commonModes)
                RunLoop.main.add(t, forMode: .defaultRunLoopMode)
            }
        } else {
            mHolidaysRequest = Service.holidays(from: mDate, to: mDate.addingTimeInterval(6.0*24.0*3600.0)) { [weak self] (r: [Holiday?]?, c: Int) in
                self?.mHolidaysRequest = nil
                if c == 200, let r = r?.flatMap({$0}), r.count > 0 {
                    self?.mActions.show(holidays: r)
                } else {
                    self?.loadHolidays(delay: 10.0)
                }
            }
        }
    }
    
    // MARK: - GMSMapViewDelegate methods
    // -------------------------------------------------------------------------
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if let p = marker.userData as? Place {
            navigationController?.pushViewController(DetailsVC(for: p), animated: true)
            return true
        }
        return false
    }
    
    func mapView(_ mapView: GMSMapView, idleAt position: GMSCameraPosition) {
        let new: CLLocation = CLLocation(latitude: position.target.latitude, longitude: position.target.longitude)
        let old: CLLocation = CLLocation(latitude: mPosition.latitude, longitude: mPosition.longitude)
        if new.distance(from: old) > 1000.0 {
            mPosition = position.target
            mActions.start(clear: true)
        }
    }
    
    // MARK: - ResultsVCDelegate methods
    // -------------------------------------------------------------------------
    func show(holiday: Holiday, category: Category?) {
        mFilter.show(holiday: holiday, category: category)
    }
    
    func location() -> CLLocationCoordinate2D? {
        return mMap.camera.target
    }
    
    func show(holidays: [Holiday]) {
        mFilter.holidays = holidays
    }
    
    func show(places: [Place], clear: Bool) {
        if clear {
            mMap.clear()
        }
        places.forEach { (p: Place) in
            p.mapMarker?.map = mMap
        }
    }
    
}
