//
//  HeaderView.swift
//  Scover
//
//  Created by Mobile App Dev on 4/26/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class EmptyHeader: UITableViewHeaderFooterView {
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        self.backgroundView?.backgroundColor = .clear
        self.contentView.backgroundColor = .clear
        self.backgroundView = UIView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        return nil
    }
    
}
