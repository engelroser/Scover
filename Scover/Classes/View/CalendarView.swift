//
//  Calendar.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/18/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

protocol CalendarViewDelegate: class {
    func changed(date:Date)
}

class CalendarView: UIView, MonthDelegate {
    
//    private let mLogo: UIImageView = {
//        let tmp: UIImageView = UIImageView(image: UIImage(named: "temp5"))
//        tmp.contentMode = .scaleAspectFit
//        return tmp
//    }()
    
    private lazy var mLeft:  UILabel = Icon.left.view(size: 14.0, color: .white, target: self, action: #selector(moveLeft))
    private lazy var mRight: UILabel = Icon.right.view(size: 14.0, color: .white, target: self, action: #selector(moveRight))
    private lazy var mName:  UILabel = .label(font: .josefinSansRegular(25.0), text: "", lines: 1, color: .white, alignment: .center)
    private lazy var mHint:  UILabel = .label(font: .regular(12.0), text: "", lines: 1, color: UIColor.white.withAlphaComponent(0.5), alignment: .center)
    
    private let mMonth: Month       = Month()
    private let mTitle: UILabel     = .label(font: .regular(12.0), text: "", lines: 1, color: .white, alignment: .center)
    private let mLine:  UIImageView = UIImageView(image: .sep())
    
    private var mDate: Date = Date()
    var date: Date {
        return mDate
    }
    
    private var mExpand: Bool = false
    var expand: Bool {
        get {
            return mExpand
        }
        set {
            mExpand = newValue
            self.frame = CGRect(origin: self.frame.origin, size: self.frame.size)
            mMonth.expand = newValue
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = CGRect(x: newValue.minX, y: newValue.minY, width: newValue.width, height: mExpand ? 375 : 190.0)
        }
    }
    
    weak var delegate: CalendarViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: CGRect(x: 0, y: 0, width: frame.width, height: 240.0))
//        addSubview(mLogo)
        addSubview(mTitle)
        addSubview(mName)
        addSubview(mLeft)
        addSubview(mLine)
        addSubview(mRight)
        addSubview(mMonth)
        addSubview(mHint)
        
        mMonth.delegate = self
        self.selected(date: mMonth.selected)
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let w: CGFloat = self.width
        let h: CGFloat = self.height
        let s: CGFloat = mMonth.expand ? -66.0 : 0.0
        
//        mLogo.frame  = CGRect(x: floor((w - 50.0)/2.0), y: floor(h - 30 - 50.0), width: 50.0, height: 50.0)
        mTitle.frame = CGRect(x: 10, y: h - 40.0, width: w - 20.0, height: 40.0)
        mLeft.frame  = CGRect(x: 0, y: s, width: 42.0, height: 70.0)
        mRight.frame = CGRect(x: w - 42.0, y: s, width: 42.0, height: 70.0)
        mName.frame  = CGRect(x: 0, y: s, width: w, height: 49)
        mLine.frame  = CGRect(x: 0, y: h-40-mLine.height, width: w, height: mLine.height)
        mHint.frame  = CGRect(x: 10.0, y: 54.0 - 7.0 + s, width: w-20.0, height: 14.0)
        
        mMonth.origin = CGPoint(x: (w - mMonth.width)/2.0, y: mMonth.expand ? 14.0 : 76.0)
        mLeft.alpha   = mExpand ? 0.0 : 1.0
        mRight.alpha  = mLeft.alpha
        mHint.alpha   = mRight.alpha
        mName.alpha   = mRight.alpha
    }
    
    func moveMonthNext() {
        mMonth.date = mMonth.date.nextMonth
    }
    
    func moveMonthBack() {
        mMonth.date = mMonth.date.previousMonth
    }
    
    @objc private func moveLeft() {
        mMonth.moveWeekBack()
    }
    
    @objc private func moveRight() {
        mMonth.moveWeekNext()
    }
    
    func update(count: UInt?) {
        if let count = count {
            mTitle.text = count == 0 ? "NO_HOLIDAYS".loc : ("\(count)"+" "+(count == 1 ? "REASON" : "REASONS").loc)
        } else {
            mTitle.text = ""
        }
    }
    
    // MARK: - MonthDelegate methods
    // -------------------------------------------------------------------------
    func selected(date: Date) {
        mDate = date
        mName.text = "WEEKDAY_\(date.weekday)".loc
        if let year = date.year {
            mHint.text = "MONTH_\(date.month)".loc + " \(year)"
        } else {
            mHint.text = "MONTH_\(date.month)".loc
        }
        delegate?.changed(date: date)
    }
    
}
