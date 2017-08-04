//
//  ResultsView.swift
//  Scover
//
//  Created by Mobile App Dev on 5/11/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

protocol ResultsViewDelegate: PlacesDelegate {
    func results(view: ResultsView, holiday: Holiday, category: Category?)
    func results(view: ResultsView, dragging: UIPanGestureRecognizer)
    func results(view: ResultsView, active: Bool)
    func resultsSelectDate(view: ResultsView)
    func resultsRefresh(view: ResultsView)
}

class ResultsView: UIView, SearchDelegate {
    
    private struct Dims {
        static let bar:    CGFloat = 42.0
        static let search: CGFloat = 48.0
    }
    
    private weak var mDelegate: ResultsViewDelegate?
    
    private lazy var mDate: UILabel = .label(font: .josefinSansRegular(15.0), text: "Monday October 25th, 2017", lines: 1, color: .white, alignment: .left)

    private lazy var mSearch: SearchField = SearchField(delegate: self)
    
    var barHeight: CGFloat {
        return Dims.bar + Dims.search
    }
    
    private lazy var mPlaces: Places = Places(delegate: self.mDelegate, header: self.mHeader)
    
    private lazy var mHeader: HolidaysHorizontal = { [weak self] () -> HolidaysHorizontal in
        let top: HolidaysHorizontal = HolidaysHorizontal()
        top.paginator = true
        top.title     = false
        top.blockPage = { [weak top, weak self] (p: Int) in
            if let items: [Holiday] = top?.items, p < items.count, let s = self {
                s.mDelegate?.resultsRefresh(view: s)
                
                if let h = top?.holiday {
                    s.mDelegate?.results(view: s, holiday: h, category: top?.category)
                }
            }
        }
        top.blockCategory = { [weak self, weak top] (c: Category) in
            if let s = self {
                s.mDelegate?.resultsRefresh(view: s)
                
                if let h = top?.holiday {
                    s.mDelegate?.results(view: s, holiday: h, category: top?.category)
                }
            }
        }
        return top
    }()
    
    var category: Category? {
        return mHeader.category
    }
    
    var holiday: Holiday? {
        return mHeader.holiday
    }
    
    var search: String {
        return mSearch.text
    }
    
    private var mHUD:   UIActivityIndicatorView = .whiteLarge
    private let mLine1: UIImageView = UIImageView(image: .sep())
    private let mLine2: UIImageView = UIImageView(image: .sep())
    private let mTop:   UIView  = UIView()
    private let mIcon:  UILabel = {
        let tmp: UILabel = Icon.calendar.view(size: 16.3, color: .white)
        tmp.frame = CGRect(x: 0, y: 0, width: 60.0, height: Dims.bar)
        return tmp
    }()
    
    private let mGrad:  CALayer = {
        let tmp: CAGradientLayer = CAGradientLayer()
        tmp.colors     = [UIColor.gradTop.cgColor, UIColor.gradBot.cgColor]
        tmp.startPoint = .zero
        tmp.endPoint   = CGPoint(x: 1.0, y: 1.0)
        return tmp
    }()
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(frame: CGRect, delegate: ResultsViewDelegate? = nil) {
        super.init(frame: frame)
        self.layer.insertSublayer(mGrad, at: 0)
        mDelegate = delegate
        addSubview(mSearch)
        addSubview(mPlaces)
        addSubview(mLine1)
        addSubview(mLine2)
        addSubview(mIcon)
        addSubview(mDate)
        addSubview(mTop)
        
        mPlaces.startLoading()
        
        mTop.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(panned(_:))))
        mTop.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w: CGFloat = self.width
        let h: CGFloat = self.height
        
        mSearch.frame = CGRect(x: 0, y: Dims.bar, width: w, height: Dims.search)
        mIcon.center  = CGPoint(x: w-mIcon.width/2.0, y: Dims.bar/2.0)
        mDate.frame   = CGRect(x: 14.0, y: 2, width: mIcon.minX-28.0, height: Dims.bar)
        mGrad.frame   = self.bounds
        mPlaces.frame = CGRect(x: 0, y: mSearch.maxY, width: w, height: h - mSearch.maxY)
        mTop.frame    = CGRect(x: 0, y: 0, width: self.width, height: Dims.bar)

        mLine1.frame  = CGRect(x: 0, y: mSearch.maxY-mLine1.height, width: w, height: mLine1.height)
        mLine2.frame  = CGRect(x: 0, y: Dims.bar, width: w, height: mLine1.height)
    }
    
    @objc private func tapped() {
        mDelegate?.resultsSelectDate(view: self)
    }
    
    @objc private func panned(_ sender: UIPanGestureRecognizer) {
        mDelegate?.results(view: self, dragging: sender)
    }
    
    func show(holidays: [Holiday], date: Date) {
        mDate.text    = date.longFormat
        mHeader.items = holidays
        mHeader.page  = 0
    }
    
    func places() -> [Place] {
        return mPlaces.items
    }
    
    func show(places: [Place], more: Bool) {
        mPlaces.items = places
        mPlaces.tableFooterView = more ? mHUD : nil
    }
    
    func append(places: [Place], more: Bool) {
        mPlaces.items.append(contentsOf: places)
        mPlaces.tableFooterView = more ? mHUD : nil
    }
    
    func startLoading() {
        mPlaces.startLoading()
    }
    
    func stopLoading() {
        mPlaces.stopLoading()
    }
    
    func show(holiday: Holiday, category: Category?) {
        mHeader.show(holiday: holiday, category: category)
    }
    
    // MARK: - SearchDelegate methods
    // -------------------------------------------------------------------------
    func search(text: String?) {
        mDelegate?.resultsRefresh(view: self)
    }
    
    func search(start: Bool) {
        mDelegate?.results(view: self, active: start)
    }
    
}
