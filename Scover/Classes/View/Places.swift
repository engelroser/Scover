//
//  Locations.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 5/5/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

protocol PlacesDelegate: TableDelegate {
    func show(place: Place)
}

class Places: CommonTable<Place, PlaceCell, EmptyHeader> {
    
    private weak var mDelegate: PlacesDelegate?
    
    var iconURL: String?

    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    init(delegate: PlacesDelegate?, actions: [Icon] = [.bookmark, .share, .arrow], header: UIView? = nil) {
        super.init(delegate: delegate, actions: actions)
        self.withSection     = false
        self.tableHeaderView = header
        self.mDelegate       = delegate
        self.actionCallback  = { [weak self] (i: Icon, p: Place) -> Void in
            if i == .share {
                GlobalAction.share(place: p)
            } else if i == .bookmark {
                GlobalAction.bookmark(place: p)
            } else if i == .cross {
                GlobalAction.delete(bookmark: p.bookmarkId, done: { [weak self] (done: Bool) in
                    if done {
                        self?.delete(item: p)
                    } else {
                        "CANT_DELETE_BOOKMARK".loc.show(in: AppDelegate.window)
                    }
                })
            } else if i == .arrow, let from = Position.shared().coords?.coordinate, let to = p.location?.coordinate {
                GlobalAction.route(from: from, to: to, done: { (r: Route) in
                    AppDelegate.window?.rootViewController?.present(UINavigationController(rootViewController: RouteVC(with: r)), animated: true)
                })
            }
        }
        self.tapCallback = { [weak delegate] (p: Place) -> Void in
            delegate?.show(place: p)
        }
    }
    
    override func configure(cell: PlaceCell, for item: Place) {
        cell.attach(place: item, icon: iconURL)
        cell.likedBlock = { (p: Place) -> Void in
            GlobalAction.place(p, like: true)
        }
        cell.dislikedBlock = { (p: Place) -> Void in
            GlobalAction.place(p, like: false)
        }
    }
    
}
