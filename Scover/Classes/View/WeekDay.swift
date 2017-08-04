//
//  WeekDay.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 18/05/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class WeekDay: UIView {
    
    static private let calendar: Calendar = Calendar.current
    
    private var mDate: Date = Date()
    var date: Date {
        get {
            return mDate
        }
        set {
            mDate = newValue
            mName.text = "\(WeekDay.calendar.component(.day, from: mDate))"
        }
    }
    
    private let mName: UILabel = .label(font: .josefinSansRegular(13.0), text: "", lines: 1, color: .white, alignment: .center)
    
    private let mSelected: UIView = {
        let tmp: UIView = UIView(frame: CGRect(x: 0, y: 0, width: 40.0, height: 40.0))
        tmp.layer.masksToBounds = true
        tmp.layer.cornerRadius = tmp.width/2.0
        tmp.backgroundColor = .black
        tmp.isHidden = true
        tmp.alpha = 0.2
        return tmp
    }()
    var selected: Bool {
        get {
            return !mSelected.isHidden
        }
        set {
            mSelected.isHidden = !newValue
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(mSelected)
        addSubview(mName)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        mSelected.center = self.bounds.center()
        mName.frame = self.bounds
    }
    
    func check(selected: Date) {
        self.selected = WeekDay.calendar.isDate(selected, inSameDayAs: self.date)
    }
    
}
