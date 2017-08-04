//
//  Filter.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 16/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class Filter: UIScrollView {
    
    private let mBlock: (Holiday, Category?)->Void
    private var mViews: [FilterBlock] = []
    private var mHolidays: [Holiday]  = []
    var holidays: [Holiday] {
        get {
            return mHolidays
        }
        set {
            mHolidays = newValue
            refresh()
        }
    }
    
    private func refresh() {
        mViews.forEach { (v: FilterBlock) in
            v.removeFromSuperview()
        }
        mViews.removeAll()
        
        if mHolidays.count > 0 {
            var origin:   CGPoint = .zero
            var maxWidth: CGFloat = 0.0
            mHolidays.enumerated().forEach({ (index: Int, h: Holiday) in
                let row: FilterBlock = FilterBlock(holiday: h, origin: origin, tap: { [weak self] (sender: FilterBlock) in
                    self?.mBlock(sender.holiday, sender.category)
                })
                row.active = index == 0
                maxWidth   = max(row.maxX, maxWidth)
                origin.y   = row.maxY
                mViews.append(row)
                addSubview(row)
            })
            self.contentSize = CGSize(width: 0, height: mViews.last?.maxY ?? 0)
            self.frame.size  = CGSize(width: maxWidth, height: min(self.contentSize.height, 150))
        }
        self.isHidden = mViews.count == 0
    }
    
    init(origin: CGPoint, block: @escaping (Holiday, Category?)->Void) {
        mBlock = block
        super.init(frame: CGRect(origin: origin, size: .zero))
        backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.layer.masksToBounds = true
        self.layer.cornerRadius  = 2.0
        self.holidays = []
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    func show(holiday: Holiday, category: Category?) {
        var desired: CGRect?
        UIView.animate(withDuration: 0.2) {
            var origin: CGPoint = .zero
            self.mViews.forEach { (b: FilterBlock) in
                if b.holiday.id == holiday.id {
                    b.active = true
                    b.activate(category: category)
                } else {
                    b.active = false
                }
                b.origin = origin
                origin.y = b.maxY
                desired  = b.active ? b.frame : desired
                
            }
            self.contentSize = CGSize(width: 0, height: self.mViews.last?.maxY ?? 0)
            self.frame.size.height = min(self.contentSize.height, 150)
            
            if let d = desired {
                if d.height >= self.height || d.minY < self.contentOffset.y {
                    self.contentOffset.y += (d.minY - self.contentOffset.y)
                } else if d.maxY > (self.contentOffset.y + self.height) {
                    self.contentOffset.y += (d.maxY - self.contentOffset.y - self.height)
                }
            }
            
        }
    }
    
}
