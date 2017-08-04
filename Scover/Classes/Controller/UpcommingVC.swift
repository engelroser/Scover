//
//  UpcommingVC.swift
//  Scover
//
//  Created by Mobile App Dev on 5/3/17.
//  Copyright © 2017 Scover. All rights reserved.
//

import UIKit

class UpcommingVC: TodayVC {
    
    override var errorString: String {
        return "ERROR_LOAD_UPCOMING".loc
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = "UPCOMMING".loc
    }
    
    override func holidays(from: Holiday.Container?) -> [Holiday]? {
        return from?.upcoming
    }
    
}
