//
//  FilterBlock.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 16/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class FilterBlock: UIView {

    private struct Dims {
        static let top:   CGFloat = 5.0
        static let left:  CGFloat = 45.0
        static let right: CGFloat = 10.0
    }
    
    private let mBlock:   (FilterBlock)->Void
    private let mHoliday: Holiday
    private lazy var mRows: [FilterRow] = { [weak self] () -> [FilterRow] in
        var tmp: [FilterRow] = []
        if let s = self {
            var origin: CGPoint = CGPoint(x: Dims.left, y: s.mMain.maxY)
            s.mHoliday.categories.enumerated().forEach { (index: Int, c: Category) in
                let r: FilterRow = FilterRow(name: c.name, origin: origin, top: 5.0, bot: 5.0, left: 12.0, color: .bulletOn2, block: { [weak self] (b: FilterRow) in
                    if let s = self {
                        s.mRows.forEach { (r: FilterRow) in
                            r.active = (r === b)
                        }
                        s.mBlock(s)
                    }
                })
                r.active = index == 0
                origin.y = r.maxY
                tmp.append(r)
            }
        }
        return tmp
    }()
    
    private lazy var mMain: FilterRow = FilterRow(name: self.mHoliday.name, origin: .zero, color: .bulletOn, block: { [weak self] (b: FilterRow) in
        if let s = self {
            s.mBlock(s)
        }
    })
    private lazy var mLine: UIView = {
        let tmp: UIView = UIView()
        tmp.backgroundColor = .lineGray
        return tmp
    }()
    
    
    var holiday: Holiday {
        return mHoliday
    }
    var category: Category? {
        var cat: Category?
        mRows.enumerated().forEach { (offset: Int, element: FilterRow) in
            if element.active && offset < mHoliday.categories.count {
                cat = mHoliday.categories[offset]
            }
        }
        return cat
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            var h: CGFloat = mMain.maxY
            var w: CGFloat = mMain.maxX
            if mActive {
                mRows.forEach { (r: FilterRow) in
                    w = max(w, r.maxX)
                    h = r.maxY
                }
            }
            super.frame = CGRect(x: newValue.minX, y: newValue.minY, width: ceil(w + Dims.right), height: h)
            forceLayout()
        }
    }
    
    private var mActive:  Bool = false
    var active: Bool {
        get {
            return mActive
        }
        set {
            mActive = newValue
            mMain.active = mActive
            mLine.alpha  = mActive ? 1.0 : 0.0
            mRows.forEach { (v: FilterRow) in
                v.alpha = mActive ? 1.0 : 0.0
            }
            self.frame = CGRect(origin: self.frame.origin, size: .zero)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(holiday: Holiday, origin: CGPoint, active: Bool = false, tap: @escaping (FilterBlock)->Void) {
        mBlock   = tap
        mHoliday = holiday
        super.init(frame: .zero)
        addSubview(mMain)
        addSubview(mLine)
        mRows.forEach { (r: FilterRow) in
            addSubview(r)
        }
        self.frame  = CGRect(origin: origin, size: .zero)
        self.active = false
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        forceLayout()
    }
    
    private func forceLayout() {
        if let f: UIView = mRows.first, let l: UIView = mRows.last {
            mLine.frame = CGRect(x: 50, y: f.center.y, width: 2, height: l.center.y - f.center.y)
            mLine.isHidden = false
        } else {
            mLine.isHidden = true
        }
    }
    
    func activate(category: Category?) {
        if let c = category, let index = mHoliday.categories.index(where: { $0.id == c.id }) {
            mRows.enumerated().forEach({ (offset: Int, element: FilterRow) in
                element.active = (offset == index)
            })
        }
    }

}
