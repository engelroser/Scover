//
//  Month.swift
//  Scover
//
//  Created by Mobile App Dev on 18/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

protocol MonthDelegate: class {
    func selected(date: Date)
}

class Month: UIView, WeekDelegate {
    
    private struct Dims {
        public static let caption: CGFloat = 15.0
        public static let row: CGFloat = 50.0
    }
    
    weak var delegate: MonthDelegate?
    
    private var mSelected: Date = Date().startOfDay
    var selected: Date {
        get {
            return mSelected
        }
        set {
            mManualWeek = nil
            mSelected = newValue
            refreshWeeks()
        }
    }
    
    private var mDate: Date = Date().startOfDay
    var date: Date {
        get {
            return mDate
        }
        set {
            mManualWeek = nil
            mDate = newValue
            refreshWeeks()
        }
    }
    
    private var mManualWeek: Int?
    
    private var mExpand: Bool = false
    var expand: Bool {
        get {
            return mExpand
        }
        set {
            mExpand = newValue
            self.frame = CGRect(x: self.minX, y: self.minY, width: self.width, height: self.height)
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    private let mCaps: [UILabel] = {
        var tmp: [UILabel] = []
        for i in 0...6 {
            var day: Int = Calendar.current.firstWeekday + i
            tmp.append(.label(font: .josefinSansRegular(13.0), text: "DAY_\(day > 7 ? day-7 : day)".loc, lines: 1, color: .white, alignment: .center))
        }
        return tmp
    }()
    
    private lazy var mWeeks: [Week] = { [weak self] () -> [Week] in
        var tmp: [Week] = []
        let cur: Int = (self?.date ?? Date()).weekOfMonth
        for i in 1...6 {
            tmp.append(Week(with: Date(timeIntervalSinceNow: TimeInterval(i-cur) * 604800.0)))
        }
        return tmp
    }()
    
    private let mWeekWrapper: UIView = {
        let tmp: UIView = UIView()
        tmp.clipsToBounds = true
        return tmp
    }()
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            let w: CGFloat = UIScreen.main.bounds.width
            super.frame = CGRect(x: newValue.minX, y: newValue.minY, width: (319 < w && w < 321 ? 280 : 336), height: (Dims.row*CGFloat(mExpand ? mWeeks.count : 1) + Dims.caption))
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.clipsToBounds = true
        mCaps.forEach { (d: UILabel) in
            addSubview(d)
        }
        addSubview(mWeekWrapper)
        mWeeks.forEach { (w: Week) in
            w.delegate = self
            mWeekWrapper.addSubview(w)
        }
        refreshWeeks()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let dw: CGFloat = self.width/7.0
        mCaps.enumerated().forEach { (offset: Int, element: UILabel) in
            element.frame = CGRect(x: floor(CGFloat(offset)*dw), y: 0, width: ceil(dw), height: Dims.caption)
        }
        
        let y: CGFloat
        if mExpand {
            y = 0.0
        } else if let manual = mManualWeek {
            y = Dims.row * CGFloat(manual-1)
        } else {
            y = Dims.row * CGFloat(mWeeks.index { $0.isSelected } ?? 0)
        }
        mWeekWrapper.frame = CGRect(x: 0, y: Dims.caption, width: self.width, height: self.height - Dims.caption)
        mWeeks.enumerated().forEach { (offset: Int, element: Week) in
            element.frame = CGRect(x: 0, y: CGFloat(offset)*Dims.row - y, width: self.width, height: Dims.row)
        }
    }
    
    @objc private func refreshWeeks() {
        let cur: Int = mDate.weekOfMonth
        mWeeks.enumerated().forEach { (offset: Int, element: Week) in
            element.refresh(date: mDate.startOfWeek.addingTimeInterval(TimeInterval(offset-cur+1) * 604800.0), month: mDate.month, selected: mSelected)
        }
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func moveWeekBack() {
        guard !mExpand else { return }
        
        if let current = mManualWeek {
            mManualWeek = current-1
        } else {
            mManualWeek = mSelected.weekOfMonth - 1
        }
        
        if let current = mManualWeek, current < 1 {
            let isFirstDay: Bool = mDate.startOfMonth.isFirstDay
            mDate = mDate.previousMonth
            mManualWeek = mDate.totalWeeks - (isFirstDay ? 0 : 1)
            refreshWeeks()
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func moveWeekNext() {
        guard !mExpand else { return }
        
        if let current = mManualWeek {
            mManualWeek = current+1
        } else {
            mManualWeek = mSelected.weekOfMonth + 1
        }

        if let current = mManualWeek, current > mDate.totalWeeks {
            mDate = mDate.nextMonth
            mManualWeek = mDate.isFirstDay ? 1 : 2
            refreshWeeks()
        } else {
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    // MARK: - WeekDelegate methods
    // -------------------------------------------------------------------------
    func tapped(day: WeekDay) {
        mManualWeek = nil
        mSelected = day.date.startOfDay
        mDate = mSelected
        refreshWeeks()
        delegate?.selected(date: mSelected)
    }
    
}
