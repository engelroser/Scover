//
//  Week.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/18/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

protocol WeekDelegate: class {
    func tapped(day: WeekDay)
}

class Week: UIView {

    private lazy var mDays: [WeekDay] = { [weak self] () -> [WeekDay] in
        var tmp: [WeekDay] = []
        for i in 0...6 {
            let day: WeekDay = WeekDay()
            day.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped(_:))))
            tmp.append(day)
        }
        return tmp
    }()
    
    weak var delegate: WeekDelegate?
    
    var isSelected: Bool {
        return mDays.first { $0.selected } != nil
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(with date: Date = Date()) {
        super.init(frame: .zero)
        mDays.forEach { (d: WeekDay) in
            addSubview(d)
        }
        refresh(date: date, month: date.month, selected: Date())
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        refreshFrames()
    }
    
    func refresh(date: Date, month: Int, selected: Date) {
        let w: CGFloat  = self.width/7.0
        let h: CGFloat  = self.height
        var s: Date     = date.startOfWeek
        mDays.enumerated().forEach { (offset: Int, element: WeekDay) in
            element.frame = CGRect(x: floor(CGFloat(offset) * w), y: 0, width: ceil(w), height: h)
            element.date  = s
            element.alpha = (month == s.month ? 1.0 : 0.5)
            element.check(selected: selected)
            s = s.addingTimeInterval(86400)
        }
    }
    
    private func refreshFrames() {
        let w: CGFloat = self.width/7.0
        let h: CGFloat = self.height
        mDays.enumerated().forEach { (offset: Int, element: WeekDay) in
            element.frame = CGRect(x: floor(CGFloat(offset) * w), y: 0, width: ceil(w), height: h)
        }
    }
    
    @objc private func tapped(_ sender: UITapGestureRecognizer) {
        if let day: WeekDay = sender.view as? WeekDay, !day.selected {
            day.selected = true
            delegate?.tapped(day: day)
        }
    }
    
}
