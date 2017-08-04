//
//  CommonTable.swift
//  Scover
//
//  Created by Mobile App Dev on 5/9/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

protocol TableDelegate: class {
    
    func didScroll(y: CGFloat)
    func footerVisible()
    func refreshed()
    
}

class CommonTable<K: Equatable, C: CommonCell, H: UITableViewHeaderFooterView>: UITableView, UITableViewDelegate, UITableViewDataSource {
    
    private enum HeaderState: CGFloat {
        case none = 0.0
        case big  = 45.0
    }
    
    private enum Keys: String {
        case cell = "cell"
        case header = "header"
        case emptyHeader = "emptyHeader"
    }
    
    private var mWithSections: Bool = true
    var withSection: Bool {
        get {
            return mWithSections
        }
        set {
            mWithSections = newValue
            reloadData()
        }
    }
    
    private let mDark:    UIView = UIView()
    private var mActions: [Icon] = [.bookmark, .share]
    
    var actionCallback: ((Icon, K)->Void)?
    var tapCallback:    ((K)->Void)?

    private lazy var mPull: PullToRefresh = PullToRefresh(fire: { [weak self] () -> Void in
        self?.tableDelegate?.refreshed()
    })
    
    private var mSections: [[K]] = []
    private var mItems: [K] = []
    var items: [K] {
        get {
            return mItems
        }
        set {
            mItems.removeAll()
            mItems.append(contentsOf: newValue)
            mSections = split(items: mItems)
            reloadData()
        }
    }
    
    weak var tableDelegate: TableDelegate?
    
    var isPullEnabled: Bool = true
    var pullOffset: CGFloat {
        get {
            return mPull.offset
        }
        set {
            mPull.offset = newValue
        }
    }
    // MARK: - Instance methods
    // -------------------------------------------------------------------------
    required init?(coder aDecoder: NSCoder) {
        return nil
    }

    init(delegate: TableDelegate? = nil, actions: [Icon] = [.bookmark, .share], action: ((Icon, K)->Void)? = nil, tap: ((K)->Void)? = nil) {
        super.init(frame: .zero, style: .plain)
        
        self.tableDelegate   = delegate
        self.rowHeight       = 80
        self.delegate        = self
        self.dataSource      = self
        self.backgroundView  = UIView()
        self.separatorStyle  = .none
        self.backgroundColor = .clear
        self.register(C.self, forCellReuseIdentifier: Keys.cell.rawValue)
        self.register(H.self, forHeaderFooterViewReuseIdentifier: Keys.header.rawValue)
        self.register(EmptyHeader.self, forHeaderFooterViewReuseIdentifier: Keys.emptyHeader.rawValue)
        
        mPull.scroll   = self
        mActions       = actions
        actionCallback = action
        tapCallback    = tap
    }
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        if self.visibleCells.count > 0 {
            var swiped: C? = nil
            self.visibleCells.forEach({ (c: UITableViewCell) in
                if let cell = c as? C, cell.swiped {
                    swiped = cell
                }
            })
            
            if let s = swiped {
                if s.point(inside: convert(point, to: s), with: event) {
                    return s.hitTest(convert(point, to: s), with: event)
                }
                s.swipeBack(animated: true)
                self.isUserInteractionEnabled = false
                DispatchQueue.main.async {
                    self.isUserInteractionEnabled = true
                }
                return nil
            }
        }
        return super.hitTest(point, with: event)
    }

    func startLoading(scroll: Bool = true) {
        mPull.start()
        if scroll && self.contentOffset.y > -self.contentInset.top {
            self.setContentOffset(CGPoint(x: 0, y: -self.contentInset.top), animated: true)
        }
    }
    
    func stopLoading() {
        mPull.stop()
    }

    private func showDarkBackground(`for` view: UIView) {
        mDark.backgroundColor = .actions
        mDark.frame = view.convert(view.bounds, to: self)
        self.insertSubview(mDark, at: 0)
    }
    
    func configure(cell: C, for item: K) {}

    func configure(header: H, `for` items: [K]) -> H {
        return header
    }
    
    func split(items: [K]) -> [[K]] {
        return [items]
    }
    
    private func headerState(`for` section: Int) -> HeaderState {
        return mWithSections ? .big : .none
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if isPullEnabled {
            mPull.check(scroll: self)
        }
    }
    
    func delete(item: K) {
        if let index = self.items.index(where: { $0 == item }) {
            self.items.remove(at: index)
        }
    }
    
    // MARK: - UITableViewDelegate, UITableViewDataSource methods
    // -------------------------------------------------------------------------
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        self.window?.endEditing(true)
        visibleCells.forEach { (c: UITableViewCell) in
            if let cell = c as? C {
                cell.swipeBack(animated: true)
            }
        }
        if isPullEnabled {
            mPull.check(scroll: self)
        }
        
        tableDelegate?.didScroll(y: scrollView.contentOffset.y)
        if let view = self.tableFooterView, let parent = self.superview {
            let tmp: CGPoint = self.convert(view.origin, to: parent)
            if tmp.y < parent.height {
                tableDelegate?.footerVisible()
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item: K = mSections[indexPath.section][indexPath.row]
        let cell: C = tableView.dequeueReusableCell(withIdentifier: Keys.cell.rawValue, for: indexPath) as! C
        cell.actions = mActions
        cell.actionCallback = { [weak self] (i: Icon) -> Void in
            self?.actionCallback?(i, item)
        }
        configure(cell: cell, for: item)
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mSections[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return mSections.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return headerState(for: section).rawValue
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if headerState(for: section) == .big, let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: Keys.header.rawValue) as? H {
            return configure(header: header, for: mSections[section])
        }
        return tableView.dequeueReusableHeaderFooterView(withIdentifier: Keys.emptyHeader.rawValue)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tapCallback?(mSections[indexPath.section][indexPath.row])
    }

}
