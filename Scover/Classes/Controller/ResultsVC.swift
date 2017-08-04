//
//  ResultsVC.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/11/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import CoreLocation
import Alamofire
import UIKit

protocol ResultsVCDelegate: class {
    func show(holiday: Holiday, category: Category?)
    func location() -> CLLocationCoordinate2D?
    func show(places: [Place], clear: Bool)
    func show(holidays: [Holiday])
}

class ResultsVC: CommonVC, ResultsViewDelegate {

    enum State: Int {
        case top = 0
        case mid = 1
        case bot = 2
    }
    
    private weak var mDelegate: ResultsVCDelegate?
    
    private var mRequest:   DataRequest?
    private var mHolidays:  [[Holiday]] = []
    private var mState:     State = .bot
    private let mStartDate: Date
    private lazy var mContent: ResultsView = ResultsView(frame: .zero, delegate: self)
    private var mToken:     String?
    
    private let mStatusBar: UIView = {
        let tmp: UIView = UIView(frame: UIApplication.shared.statusBarFrame)
        tmp.backgroundColor = .main
        return tmp
    }()
    
    private var mStart: CGFloat = 0.0
    private var mViewY: CGFloat = 0.0
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(date: Date, delegate: ResultsVCDelegate? = nil) {
        mStartDate = date
        super.init(nibName: nil, bundle: nil)
        mDelegate = delegate
    }
    
    override func isGgradien() -> Bool {
        return false
    }

    override func loadView() {
        self.view = TransView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(mStatusBar)
        view.addSubview(mContent)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let w: CGFloat = self.view.width
        let h: CGFloat = self.view.height
        mStatusBar.frame = CGRect(x: 0, y: 0, width: w, height: mStatusBar.height)
        switch mState {
        case .bot: mContent.frame = CGRect(x: 0, y: h - mContent.barHeight, width: w, height: h-mStatusBar.maxY)
        case .mid: mContent.frame = CGRect(x: 0, y: mContent.minY, width: w, height: h-mStatusBar.maxY)
        case .top: mContent.frame = CGRect(x: 0, y: mStatusBar.maxY, width: w, height: h-mStatusBar.maxY)
        }
    }
    
    deinit {
        mRequest?.cancel()
        mRequest = nil
    }
    
    private func set(state: State, animated: Bool) {
        if state == .bot {
            view.endEditing(true)
        }
        
        let block: ()->Void = {
            self.mState = state
            self.view.setNeedsLayout()
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.25, animations: block)
        } else {
            block()
        }
    }
    
    func show(holidays: [Holiday]) {
        mHolidays.removeAll()
        var last: [Holiday] = []
        holidays.enumerated().forEach { (offset: Int, element: Holiday) in
            if offset == 0 {
                last = []
            } else if let prx = holidays[offset-1].date, let cur = holidays[offset].date, cur != prx {
                mHolidays.append(last)
                last = []
            }
            last.append(element)
        }
        if last.count > 0 {
            mHolidays.append(last)
        }
        select(day: 0)
    }
    
    private func select(day: Int) {
        if day < mHolidays.count {
            mContent.show(holidays: mHolidays[day], date: mStartDate.addingTimeInterval(TimeInterval(day) * 24.0 * 3600.0))
            mDelegate?.show(holidays: mHolidays[day])
        }
    }
    
    func start(clear: Bool = false) {
        guard let l = mDelegate?.location(), let c = mContent.category, let h = mContent.holiday else {
            mContent.stopLoading()
            return
        }
        if clear {
            mContent.show(places: [], more: false)
        }
        
        mContent.startLoading()
        mRequest?.cancel()
        mRequest = Service.locations(search: mContent.search, holiday: h.id, category: c.id, location: l, callback: { [weak self] (p: Place.List?, code: Int) in
            guard let s = self else { return }
            if code == 200, let p = p {
                s.mContent.show(places: p.results, more: p.next_page_token != nil)
                s.mToken = p.next_page_token
                s.mDelegate?.show(places: p.results, clear: clear)
            } else {
                "CANT_LOAD_PLACES".loc.show(in: s.view.window)
            }
            s.mContent.stopLoading()
            s.mRequest = nil
        });
    }
    
    func select(holiday: Holiday, category: Category?) {
        mContent.show(holiday: holiday, category: category)
    }
    
    // MARK: - ResultsViewDelegate methods
    // -------------------------------------------------------------------------
    func results(view: ResultsView, dragging: UIPanGestureRecognizer) {
        switch dragging.state {
        case .began:
            self.view.endEditing(true)
            mState = .mid
            mStart = dragging.location(in: self.view).y
            mViewY = view.convert(.zero, to: self.view).y
        case .changed:
            view.frame.origin.y = min(max(dragging.location(in: self.view).y - mStart + mViewY, mStatusBar.maxY), self.view.height - view.barHeight)
        default:
            set(state: dragging.velocity(in: self.view).y > 0 ? .bot : .top, animated: true)
        }
    }
    
    func results(view: ResultsView, holiday: Holiday, category: Category?) {
        mDelegate?.show(holiday: holiday, category: category)
    }
    
    func resultsRefresh(view: ResultsView) {
        start(clear: true)
    }
    
    func results(view: ResultsView, active: Bool) {
        if mState == .bot && active {
            set(state: .top, animated: true)
        } else if mState == .top && !active {
            set(state: .bot, animated: true)
        }
    }
    
    func resultsSelectDate(view: ResultsView) {
        if mHolidays.count > 0 {
            navigationController?.present(UINavigationController(rootViewController: SelectDayVC(from: mHolidays, callback: { [weak self] (day: Int) -> Void in
                self?.select(day: day)
            })), animated: true)
        }
    }
    
    // MARK: - PlacesDelegate methods
    // -------------------------------------------------------------------------
    func didScroll(y: CGFloat) {}
    
    func show(place: Place) {
        parent?.navigationController?.pushViewController(DetailsVC(for: place), animated: true)
    }
    
    func footerVisible() {
        if let h = mContent.holiday, mRequest == nil, let t = mToken {
            mRequest = Service.locations(for: h.id, next: t, callback: { [weak self] (p: Place.List?, c: Int) in
                if let p = p, c == 200 {
                    self?.mContent.append(places: p.results, more: p.next_page_token != nil)
                    self?.mToken = p.next_page_token
                } else {
                    "CANT_LOAD_PLACES".loc.show(in: self?.view.window)
                }
                self?.mRequest = nil
            })
        }
    }
    
    func refreshed() {
        start()
    }

}
