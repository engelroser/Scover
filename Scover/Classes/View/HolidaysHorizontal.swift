//
//  SponsorBlock.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/5/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class HolidaysHorizontal: UIView, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private struct Dims {
        static let width:  CGFloat = 300.0
        static let height: CGFloat = 200.0
        
        static let max: CGFloat = 270.0
        static let gap: CGFloat = 10.0
    }
    
    private lazy var mTable: UICollectionView = { [weak self] () -> UICollectionView in
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = .zero
        layout.scrollDirection = .horizontal
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 8
        layout.itemSize = CGSize(width: Dims.width, height: Dims.height)
        
        let tmp: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        tmp.dataSource = self
        tmp.delegate   = self
        tmp.backgroundView   = UIView()
        tmp.backgroundColor  = .clear
        tmp.clipsToBounds    = false
        tmp.decelerationRate = UIScrollViewDecelerationRateFast
        tmp.register(HolidayCard.self, forCellWithReuseIdentifier: "cell")
        tmp.showsVerticalScrollIndicator   = false
        tmp.showsHorizontalScrollIndicator = false
        return tmp
    }()
    
    private let mTitle: UILabel = .label(font: .regular(12.0), text: "SCOVER_REC".loc, lines: 1, color: .white, alignment: .center)
    
    private var mNotify: Bool = true
    private var mPage:   Int  = 0
    private let mPages:  Paginator = Paginator(pages: 0)
    
    var holiday: Holiday? {
        return mPage < self.items.count ? self.items[mPage] : nil
    }
    
    var category: Category? {
        var cat: Category? = nil
        mTable.indexPathsForVisibleItems.forEach { (p: IndexPath) in
            if p.row == mPage, let cell = mTable.cellForItem(at: p) as? HolidayCard {
                cat = cell.category
            }
        }
        return cat
    }
    
    var blockPage: ((Int)->Void)?
    var blockCategory: ((Category)->Void)?

    var paginator: Bool {
        get {
            return !mPages.isHidden
        }
        set {
            mPages.isHidden = !newValue
            self.frame = normalize(frame: self.frame)
        }
    }
    
    var title: Bool {
        get {
            return !mTitle.isHidden
        }
        set {
            mTitle.isHidden = !newValue
            self.frame = normalize(frame: self.frame)
        }
    }
    
    override var frame: CGRect {
        get {
            return super.frame
        }
        set {
            super.frame = normalize(frame: newValue)
        }
    }
    
    var page: Int {
        get {
            return mPage
        }
        set {
            if newValue < mPages.pages {
                mPage = newValue
                mTable.setContentOffset(CGPoint(x: calculateOffset(scroll: mTable, velocity: .zero), y: 0), animated: false)
            }
        }
    }
    
    private var mItems: [Holiday] = []
    var items: [Holiday] {
        get {
            return mItems
        }
        set {
            mItems = newValue
            mPages.pages = mItems.count
            mTitle.alpha = mItems.count > 0 ? 1.0 : 0.0
            mPages.alpha = mItems.count > 0 ? 1.0 : 0.0
            mTable.reloadData()
            
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    init(page pageBlock: ((Int)->Void)? = nil, category categoryBlock: ((Category)->Void)? = nil) {
        super.init(frame: .zero)
        addSubview(mTable)
        addSubview(mPages)
        addSubview(mTitle)
        
        blockPage     = pageBlock
        blockCategory = categoryBlock
        
        self.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 0)
        self.items = []
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let w: CGFloat = self.width
        let h: CGFloat = self.height
        
        mTable.frame  = CGRect(x: 0, y: self.title ? (Dims.max - Dims.height)/2.0 : Dims.gap, width: w, height: Dims.height)
        mPages.origin = CGPoint(x: (w - mPages.width)/2.0, y: (h + mTable.maxY - mPages.height)/2.0)
        mTitle.origin = CGPoint(x: floor((w - mTitle.width)/2.0), y: floor((mTable.minY - mTitle.height)/2.0))
        mTable.contentInset = UIEdgeInsetsMake(0, (w-Dims.width)/2.0, 0, (w-Dims.width)/2.0)
        mTable.reloadData()
        mTable.setNeedsLayout()
        mTable.layoutIfNeeded()
        
        mTable.setContentOffset(CGPoint(x: calculateOffset(scroll: mTable, velocity: .zero), y: 0), animated: false)
    }
    
    private func calculateOffset(scroll view: UIScrollView, velocity: CGPoint) -> CGFloat {
        if velocity.x < -0.2 || velocity.x > 0.2 {
            mPage = velocity.x > 0 ? mPage + 1 : mPage - 1
            mPage = min(mPages.pages-1, mPage)
            mPage = max(0, mPage)
        }
        return CGFloat(mPage) * Dims.width - (self.width-Dims.width)/2.0
    }
    
    private func normalize(frame: CGRect) -> CGRect {
        var height: CGFloat = Dims.max
        if mTitle.isHidden {
            height -= (Dims.max - Dims.height)/2.0 - Dims.gap
        }
        if mPages.isHidden {
            height -= (Dims.max - Dims.height)/2.0 - Dims.gap
        }
        return CGRect(x: frame.minX, y: frame.minY, width: frame.width, height: height)
    }
    
    func show(holiday: Holiday, category: Category?) {
        if let index = mItems.index(of: holiday), index < mPages.pages {
            mPage   = index
            mNotify = false
            mTable.setContentOffset(CGPoint(x: calculateOffset(scroll: mTable, velocity: .zero), y: 0), animated: false)
            mTable.visibleCells.forEach({ (c: UICollectionViewCell) in
                if let c = c as? HolidayCard {
                    c.category = category
                }
            })
            mNotify = true
            self.blockPage?(mPage)
        }
    }
    
    // MARK: - UICollectionViewDataSource && UICollectionViewDelegate methods
    // -------------------------------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if mPages.active != mPage && mPage < mItems.count && mTable.visibleCells.count > 0 {
            mPages.active = mPage
            if mNotify {
                let page: Int = mPage
                DispatchQueue.main.async {
                    self.blockPage?(page)
                }
            }
        }
        let w: CGFloat = scrollView.width
        let c: CGFloat = mTable.center.x
        mTable.visibleCells.forEach { (cell: UICollectionViewCell) in
            if let p = cell as? HolidayCard {
                p.scale = min(abs(c - p.convert(CGPoint(x: p.width/2.0, y: p.height/2.0), to: self).x), w) / w
            }
        }
    }
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        targetContentOffset.pointee.x = calculateOffset(scroll: scrollView, velocity: velocity)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: HolidayCard = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! HolidayCard
        cell.holiday = mItems[indexPath.row]
        cell.block = { [weak self] (c: Category) -> Void in
            self?.blockCategory?(c)
        }
        DispatchQueue.main.async {
            self.scrollViewDidScroll(self.mTable)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
    }
    
}
