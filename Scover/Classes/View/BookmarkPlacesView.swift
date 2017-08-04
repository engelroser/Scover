//
//  BookmarkPlaces.swift
//  Scover
//
//  Created by Kirill Kozhuhar on 09/06/2017.
//  Copyright © 2017 Scover. All rights reserved.
//

import Alamofire
import UIKit

protocol BookmarkPlacesViewDelegate: class {
    func tapped(place: Place)
}

class BookmarkPlacesView: CommonBookmark<Place, PlaceCell, EmptyHeader>, PlacesDelegate {
    
    private weak var mDelegate: BookmarkPlacesViewDelegate?
    
    init(delegate: BookmarkPlacesViewDelegate? = nil) {
        super.init(frame: .zero)
        mDelegate = delegate
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
    override func generateTable() -> CommonTable<Place, PlaceCell, EmptyHeader> {
        return Places(delegate: self, actions: [.share, .cross, .arrow])
    }
    
    override func doRequest(search: String, offset: UInt64, limit: UInt64, block: @escaping ([Place]?, Int, UInt64?) -> Void) -> DataRequest? {
        return Service.bookmarkPlaces(search: search, offset: offset, limit: limit, callback: { (p: Place.Bookmark?, c: Int) in
            block(p?.locations, c, p?.total)
        })
    }
    
    // MARK: - PlacesDelegate methods
    // -------------------------------------------------------------------------    
    func show(place: Place) {
        mDelegate?.tapped(place: place)
    }
    
}
